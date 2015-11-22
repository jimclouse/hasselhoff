USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

# login must have ALTER permissions on all the tables for this script to work

IF EXISTS (select 1 from sys.extended_properties where major_id = {{objectId}} {{#columnId}} and minor_id = {{columnId}} {{/columnId}})
BEGIN
	EXEC sp_updateextendedproperty @name = 'MS_Description', @value = '{{{description}}}',
		@level0type = N'SCHEMA', @level0name = '{{schemaName}}',
		@level1type = N'TABLE',  @level1name = '{{tableName}}'
		{{#columnName}}
		,@level2type = N'Column', @level2name = '{{columnName}}'
		{{/columnName}}
END
ELSE
BEGIN
	EXEC sp_addextendedproperty @name = 'MS_Description', @value = '{{{description}}}',
		@level0type = N'SCHEMA', @level0name = '{{schemaName}}',
		@level1type = N'TABLE',  @level1name = '{{tableName}}'
		{{#columnName}}
		,@level2type = N'Column', @level2name = '{{columnName}}'
		{{/columnName}}
END