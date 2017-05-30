class BrandDatatable < AjaxDatatablesRails::Base

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      name: { source: "brands.name", cond: :eq },
      brand_type: { source: "brands.brand_type", cond: :eq },
      external: { source: "brands.external", cond: :eq }
    }
  end
  
  def sortable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.name'
    @sortable_columns ||= []
  end

  def searchable_columns
    # list columns inside the Array in string dot notation.
    # Example: 'users.name'
    @searchable_columns ||= []
  end


  def data
    @brands.map do |record|
      [
        record.name,
        record.brand_type.name,
        record.external
      ]
    end
  end

  private

  def get_raw_records
    # insert query here
    @brands = Marketshare::Brand.all.includes(:brand_type)
  end

  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary
end
