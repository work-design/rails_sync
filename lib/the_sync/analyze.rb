module TheSync::Analyze

  def analyze_diffs
    query = analyze_table.join(dest_table).on(my_table[primary_key].eq(dest_table[@source_pk]))
    query.where(analyze_conditions)

    results = connection.execute(query.to_sql)
  end


  def analyze_inserts
    query = analyze_table.join(dest_table, Arel::Nodes::OuterJoin).on(my_table[primary_key].eq(dest_table[@source_pk]))
    query.where(analyze_conditions)

    results = connection.execute(query.to_sql)
  end


  def analyze_deletes
    query = analyze_table.join(dest_table, Arel::Nodes::RightOuterJoin).on(my_table[primary_key].eq(dest_table[@source_pk]))
    query.where(analyze_conditions)

    results = connection.execute(query.to_sql)
  end

  def analyze_table
    attrs = @source_columns.map { |col| my_table[col] }
    my_table.project(*attrs)
  end

  def my_table
    @my_table ||= Arel::Table.new(self.table_name)
  end

  def dest_table
    @dest_table ||= Arel::Table.new(@view_name)
  end

  def analyze_conditions
    first_mapping = @full_mappings[0]
    condition = my_table[first_mapping[0]].not_eq(dest_table[first_mapping[1]])
    @full_mappings[1..-1].each do |mapping|
      condition = condition.or( my_table[mapping[0]].not_eq(dest_table[mapping[1]]) )
    end
    condition
  end

end
