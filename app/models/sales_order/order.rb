class SalesOrder::Order < ActiveRecord::Base
  #establish_connection "dbmarketing".to_sym
  self.table_name = "sales_outstanding_orders" #sd
  #SDSRP1, SDSRP2, SDUORG
  #HELD ORDRES TABLE (HO)
  
  def self.check_forecast(branch, start_day, end_day, item)
    branch_check = jde_cabang(branch.split('|', 2).first.gsub('$', ''))
    fc = find_by_sql("SELECT sum(quantity) AS qty FROM dbmarketing.forecasts WHERE branch = '#{branch_check}' AND 
    month = '#{end_day.to_date.month}' AND year = '#{end_day.to_date.year}' AND item_number = '#{item.strip}' 
    GROUP BY item_number, branch")
    fc.empty? ? 0 : fc.first.qty
  end
  
  def self.generate_proving_reports(branch, start_day, end_day)
    Jde.find_by_sql("
      SELECT '#{branch}' AS PARAMSBRANCH, '#{start_day.to_date}' AS PARAMSSTART,
        '#{end_day.to_date}' AS PARAMSEND, PO.SDITM, MAX(PO.SDLITM) AS SDLITM, MAX(PO.DESCRIPTION) AS DESCRIPTION, 
          MAX(PO.BRAND) AS BRAND, NVL(MAX(IB.SAFETY/10000),0) AS BUFFER, SUM(PO.QTY_PBJ/10000) AS PBJ, SUM(PO.OUTSTANDING_PBJ/10000) AS OUTSTANDING_PBJ,
          NVL(SUM(LEDGER.IN_RECEIPT)/10000,0) AS IN_STOCK, NVL(SUM(PO.PEMENUHAN/10000),0) AS QTY_OFF, 
          NVL(SUM(BO.QTY)/10000,0) AS OUTSTANDING_SO, NVL(SUM(ST.ONHAND/10000),0) AS ONHAND, 
          NVL(SUM(IV.SELL_OUT)/100,0) AS SELL, ROUND(AVG(PO.SDTRDJ), 2) AS ORDER_DATE, 
          NVL(ROUND(AVG(LEDGER.ILCRDJ),2),0) AS RECEIPT, NVL(ROUND((AVG(LEDGER.ILCRDJ)-AVG(PO.SDTRDJ)),2),0) AS LEADTIME FROM
          (
          SELECT SDMCU, SDITM, MAX(SDLITM) AS SDLITM, SDSHAN, SUM(SDUORG) AS QTY_PBJ, MAX(SDRCTO) AS SDRCTO, MAX(SDRORN) AS SDRORN, 
            MAX(SDTRDJ) AS SDTRDJ, MAX(SDSRP1) AS SDSRP1, 
            NVL(SUM(CASE WHEN SDNXTR <= '560' AND SDLTTR <= '540' THEN SDUORG END), 0) AS OUTSTANDING_PBJ,
            NVL(SUM(CASE WHEN SDADDJ > SDOPDJ AND SDNXTR = '999' AND SDLTTR = '580' THEN SDUORG END), 0) AS PEMENUHAN,
            CONCAT(CONCAT(TRIM(MAX(SDDSC1)), ' '), TRIM(MAX(SDDSC2))) AS DESCRIPTION, MAX(SDSRP1) AS BRAND,
            MIN(SDVR01) AS CUSTOMER_PO FROM PRODDTA.F4211 
            WHERE REGEXP_LIKE(SDMCU, '11001|11002|12001|12002|15151|15152|11051|11052|11081|11082|11091|11092')
            AND REGEXP_LIKE(SDSHAN, '#{branch}') AND SDTRDJ BETWEEN '#{date_to_julian(start_day.to_date)}' 
            AND '#{date_to_julian(end_day.to_date)}' AND SDCOMM != 'K'
            AND SDDCTO != 'CO'
            GROUP BY SDITM, SDSHAN, SDMCU
          ) PO
          LEFT JOIN
          (
            SELECT LEDGER.ILMCU AS TO_BP, LEDGER.ILAN8 AS FROM_BP, LEDGER.ILITM AS SHORT_I, 
            MAX(LEDGER.ILCRDJ) AS ILCRDJ,
            SUM(CASE WHEN LEDGER.ILCRDJ BETWEEN '#{date_to_julian(start_day.to_date)}' 
            AND '#{date_to_julian(end_day.to_date)}' THEN ILTRQT END) IN_RECEIPT
            FROM PRODDTA.F4111 LEDGER WHERE LEDGER.ILCRDJ BETWEEN '#{date_to_julian(start_day.to_date)}' 
            AND '#{date_to_julian(end_day.to_date)}' AND LEDGER.ILDCTO IN ('OK', 'OT') AND LEDGER.ILAN8 > 0 
            AND LEDGER.ILDCT IN ('OV', 'VT') AND 
            REGEXP_LIKE(LEDGER.ILAN8, '11001$|11002$|12002$|12001$|15001$|15002$|15151$|15152$|11051$|11052$|11081$|11082$|11091$|11092$')
            GROUP BY LEDGER.ILITM, LEDGER.ILAN8, LEDGER.ILMCU
          ) LEDGER ON LEDGER.SHORT_I = PO.SDITM AND LEDGER.TO_BP LIKE '%'||PO.SDSHAN
          LEFT JOIN
          (
            SELECT IBITM, MAX(IBSRP1) AS IBSRP1, SUM(IBSAFE) AS SAFETY, IBMCU FROM PRODDTA.F4102 WHERE IBSAFE > 0 
            GROUP BY IBITM, IBMCU
          ) IB ON IB.IBMCU LIKE '%'||PO.SDSHAN AND IB.IBSRP1 LIKE PO.SDSRP1||'%' AND IB.IBITM = PO.SDITM
          LEFT JOIN
          (
            SELECT LIITM, LIMCU, SUM(LIPQOH) AS ONHAND, SUM(LIHCOM) AS COMIT FROM PRODDTA.F41021 
            WHERE (LIHCOM > 0 or LIPQOH > 0) GROUP BY LIITM, LIMCU
          ) ST ON ST.LIITM = PO.SDITM AND ST.LIMCU = PO.SDMCU
          LEFT JOIN
          (
            SELECT SDITM, MAX(SDLITM) AS SDLITM, SDMCU, SUM(SDUORG) AS QTY, MIN(SDDRQJ) AS SO_REQDATE FROM PRODDTA.F4211 
            WHERE SDNXTR = '525' AND SDDCTO = 'SO' AND REGEXP_LIKE(SDMCU, '#{branch}') AND 
            SDCOMM != 'K' AND SDDRQJ <= '#{date_to_julian(end_day.to_date)}'
            GROUP BY SDITM, SDMCU
          ) BO ON PO.SDITM = BO.SDITM AND TRIM(PO.SDSHAN) = TRIM(BO.SDMCU)
          LEFT JOIN
          (
            SELECT RPMCU, RPRMK, SUM(RPU) AS SELL_OUT FROM PRODDTA.F03B11 WHERE RPDIVJ BETWEEN '#{date_to_julian(start_day.to_date)}' 
            AND '#{date_to_julian(end_day.to_date)}' AND RPDCT = 'RI' 
            GROUP BY RPMCU, RPRMK
          ) IV ON TRIM(PO.SDLITM) = TRIM(IV.RPRMK) AND PO.SDSHAN LIKE '%'||TRIM(IV.RPMCU)
      WHERE PO.BRAND != ' ' GROUP BY PO.SDITM
    ")
  end
  
  def self.checking_forecast(item, branch, month, year)
    
  end
  
  def self.checking_available(onhand, commit)
    commit > onhand ? 0 : (onhand - commit)
  end
  
  def self.leadtime(to_branch, item)
    lead = find_by_sql("
      SELECT short_item, description, from_branch, to_branch, AVG(fulfillment_day) AS fulfill
      FROM warehouse.LEADTIMES WHERE to_branch = '#{to_branch.strip}' AND short_item = '#{item}' GROUP BY short_item
    ")
    lead.empty? ? '-' : lead.first.fulfill
  end
  
  def self.generate_pbj(branch, brand)
    Jde.find_by_sql("
      SELECT IM.IMITM, IM.IMLITM AS ITEM_NUMBER, NVL(BO.SDMCU, IB.IBMCU) AS BRANCH_PLAN, NVL(BO.SO_REQDATE, 0) AS SO_REQDATE, 
      NVL(IB.SAFETY/10000,0) AS SAFETY_STOCK, NVL(BO.QTY/10000,0) AS QTY_ORDER, 
      NVL(ST.ONHAND/10000,0) AS ONHAND, NVL(ST.COMIT/10000, 0) AS COMIT, 
      NVL(PO.QTY_OUTS/10000, 0) AS QTY_OUTS, NVL(PO.QTY_COMMIT/10000, 0) AS QTY_COMMIT,
      CONCAT(CONCAT(TRIM(IM.IMDSC1), ' '), TRIM(IM.IMDSC2)) AS DESCRIPTION,
      NVL(PO.SDMCU, '-') AS PBJ_BP, NVL(PO.PO_PROMISE, 0) AS PO_PROMISEDATE, NVL(PO.CUSTOMER_PO, '-') AS CUSTOMER_PO FROM
      (
        SELECT IBITM, SUM(IBSAFE) AS SAFETY, IBMCU FROM PRODDTA.F4102 WHERE IBSAFE > 0 
        AND IBMCU LIKE '%#{branch}' AND IBSRP1 LIKE '#{brand}%' GROUP BY IBITM, IBMCU
      ) IB
      FULL OUTER JOIN
      (
        SELECT SDITM, MAX(SDLITM) AS SDLITM, SDMCU, SUM(SDUORG) AS QTY, MIN(SDDRQJ) AS SO_REQDATE FROM PRODDTA.F4211 
        WHERE SDNXTR = '525' AND SDDCTO = 'SO' AND SDMCU LIKE '%#{branch}' AND 
        (SDSRP1 LIKE '#{brand}%' OR SDSRP1 LIKE 'K%') AND SDCOMM != 'K'
        GROUP BY SDITM, SDMCU
      ) BO ON IB.IBITM = BO.SDITM
      LEFT JOIN
      (
        SELECT LIITM, LIMCU, SUM(LIPQOH) AS ONHAND, SUM(LIHCOM) AS COMIT FROM PRODDTA.F41021 
        WHERE LIMCU LIKE '%#{branch}' AND (LIHCOM > 0 or LIPQOH > 0) GROUP BY LIITM, LIMCU
      ) ST ON (ST.LIITM = BO.SDITM OR ST.LIITM = IB.IBITM) AND (ST.LIMCU = BO.SDMCU OR ST.LIMCU = IB.IBMCU)
      LEFT JOIN
      (
        SELECT SDMCU, SDITM, MAX(SDLITM) AS SDLITM, SDSHAN, 
        SUM(CASE WHEN SDNXTR <= '525' THEN SDUORG END) AS QTY_OUTS,
        SUM(CASE WHEN SDNXTR BETWEEN '540' AND '560' THEN SDUORG END) AS QTY_COMMIT,  
        MAX(SDDRQJ) AS PO_PROMISE, 
        MIN(SDVR01) AS CUSTOMER_PO FROM PRODDTA.F4211 WHERE SDNXTR < '580' 
        AND REGEXP_LIKE(SDMCU, '11001|11002|12001|12002|15151|15152|11051|11052|11081|11082|11091|11092')
        AND SDSHAN LIKE '%#{branch}' 
        GROUP BY SDITM, SDSHAN, SDMCU
      ) PO ON PO.SDITM = NVL(BO.SDITM, IB.IBITM)
      JOIN
      (
        SELECT IMITM, IMLITM, IMDSC1, IMDSC2 FROM PRODDTA.F4101 GROUP BY IMITM, IMLITM, IMDSC1, IMDSC2
      ) IM ON IM.IMITM = NVL(BO.SDITM, IB.IBITM)
    ")
  end
  
  def self.held_orders_by_approval(branch, brand)
    find_by_sql("SELECT * FROM hold_orders WHERE hdcd = 'C2' AND branch = '#{branch}' AND brand = '#{brand}' 
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.held_orders_by_credit(branch, brand)
    find_by_sql("SELECT * FROM hold_orders WHERE hdcd = 'C1' AND branch = '#{branch}' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.order_summary
  end
  
  def self.outstand_order(branch, brand)
    Jde.find_by_sql("SELECT so.sddoco AS order_no, so.sddrqj as promised_delivery, so.sdnxtr as status, 
    so.sduorg AS jumlah, so.sdtrdj AS sdtrdj,
    so.sdsrp1 AS sdsrp1, so.sdmcu AS sdmcu, so.sditm, so.sdlitm AS sdlitm, 
    so.sddsc1 AS sddsc1, so.sddsc2 AS sddsc2, itm.imseg1 AS imseg1,
    cus.abalph AS abalph, so.sdshan, cus.abat1 AS abat1,
    so.sdtorg AS sdtorg, so.sdpsn, so.sdlttr, so.sddcto, so.sdlotn, so.sdvr01
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    JOIN PRODDTA.F0101 cus ON so.sdshan = cus.aban8
    WHERE so.sdcomm NOT LIKE '%K%' AND so.sdmcu LIKE '%#{branch}%' AND so.sdsrp1 = '#{brand}'
    AND REGEXP_LIKE(so.sddcto,'SO|ZO') AND itm.imtmpl LIKE '%BJ MATRASS%' AND
    so.sdlttr <= '560'")
  end
  
  def self.pick_order(branch, brand)
    find_by_sql("SELECT * FROM outstanding_shipments WHERE branch = '#{branch}' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.get_forecast(item_number, branchplan, date)
    date = julian_to_date(date)
    a = find_by_sql("
      SELECT * FROM dbmarketing.forecasts WHERE item_number = '#{item_number.strip}' AND branch = '#{jde_cabang(branchplan.strip)}'
      AND MONTH = '#{date.to_date.month}' AND year = '#{date.to_date.year}' LIMIT 1
    ")
    (a.nil? || a.empty?) ? 0 : a.first.quantity
  end
  
  private
  
  def self.positive_checking(val)
    val >= 1 ? val : 0 
  end
  
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end
  
  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      Date.today
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD').strftime("%d/%m/%Y")
    end
  end
  
  def self.jde_cabang(bu)
    if bu == "11001" || bu == "11001D" || bu == "11001C" || bu == "18001" #pusat
      "01"
    elsif bu == "11101" || bu == "11102" || bu == "11101C" || bu == "11101D" || bu == "11101S" || bu == "18101" || bu == "18101C" || bu == "18101D" || bu == "18102" || bu == "18101S" || bu == "18101K" #lampung
      "13" 
    elsif bu == "18011" || bu == "18011C" || bu == "18011D" || bu == "18012" || bu == "18011S" || bu == "18011K" #jabar
      "02"
    elsif bu == "18021" || bu == "18021C" || bu == "18021D" || bu == "18022" || bu == "18021S" || bu == "18021K" #cirebon
      "09"
    elsif bu == "12001" || bu == "12002" || bu == "12001C" || bu == "12001D" #bestari mulia
      "50"
    elsif bu == "12061" || bu == "12062" || bu == "12001" || bu == "12061C" || bu == "12061D" || bu == "12061S" || bu == "18061" || bu == "18061C" || bu == "18061D" || bu == "18061S" #surabaya
      "07"
    elsif bu == "18151" || bu == "18151C" || bu == "18151D" || bu == "18152" || bu == "18151S" || bu == "18151K" || bu == "11151" #cikupa
      "23"
    elsif bu == "11030" || bu == "11031" ||  bu == "18031" || bu == "18031C" || bu == "18031D" || bu == "18032" || bu == "18031S" || bu == "18031K" #narogong
      "03"
    elsif bu == "12111" || bu == "12112" || bu == "12111C" || bu == "12111D" || bu == "12111S" || bu == "18111" || bu == "18111C" || bu == "18111D" || bu == "18112" || bu == "18111S" || bu == "18111K" || bu == "18112C" || bu == "18112D" || bu == "18112K" #makasar
      "19"
    elsif bu == "12071" || bu == "12072" || bu == "12071C" || bu == "12071D" || bu == "12071S" || bu == "18071" || bu == "18071C" || bu == "18071D" || bu == "18072" || bu == "18071S" || bu == "18071K" || bu == "18072C" || bu == "18071D" || bu == "18071K" #bali
      "04"
    elsif bu == "12131" || bu == "12132" || bu == "12131C" || bu == "12131D" || bu == "12131S" || bu == "18131" || bu == "18131C" || bu == "18131D" || bu == "18132" || bu == "18131S" || bu == "18131K" || bu == "18132C" || bu == "18132D" || bu == "18132K" #jember
      "22" 
    elsif bu == "11091" || bu == "11092" || bu == "11091C" || bu == "11091D" || bu == "11091S" || bu == "18091" || bu == "18091C" || bu == "18091D" || bu == "18092" || bu == "18091S" || bu == "18091K" || bu == "18092C" || bu == "18092D" || bu == "18092K" #palembang
      "11"
    elsif bu == "11041" || bu == "11042" || bu == "11041C" || bu == "11041D" || bu == "11041S" || bu == "18041" || bu == "18041C" || bu == "18041D" || bu == "18042" || bu == "18042S" || bu == "18042K" || bu == "18042C" || bu == "18042D" || bu == "18042K" #yogyakarta
      "10"
    elsif bu == "11051" || bu == "11052" || bu == "11051C" || bu == "11051D" || bu == "11051S" || bu == "18051" || bu == "18051C" || bu == "18051D" || bu == "18052" || bu == "18051S" || bu == "18051K" || bu == "18052C" || bu == "18052D" || bu == "18052K" #semarang
      "08"
    elsif bu == "11081" || bu == "11082" || bu == "11081C" || bu == "11081D" || bu == "11081S" || bu == "18081" || bu == "18081C" || bu == "18081D" || bu == "18082" || bu == "18081S" || bu == "18081K" || bu == "18082C" || bu == "18082D" || bu == "18082K" #medan
      "05"
    elsif bu == "11121" || bu == "11122" || bu == "11121C" || bu == "11121D" || bu == "11121S" || bu == "18121" || bu == "18121C" || bu == "18121D" || bu == "18122" || bu == "18121S" || bu == "18121K" || bu == "18122C" || bu == "18122D" || bu == "18122K" #pekanbaru
      "20"
    elsif bu.include?('180120') || bu.include?("180110") #tasikmalaya
      "02"
    elsif bu.include?('1515') #new cikupa
      "23"
    elsif bu == "12171" || bu == "12172" || bu == "12171C" || bu == "12171D" || bu == "12171S" || bu == "18171" || bu == "18172" || bu == "18171C" || bu == "18171D" || bu == "18171S" || bu == "18172D" || bu == "18172" || bu == "18172K" #manado
      "26"
    end
  end
end