SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_ddc_mapping]
AS
begin

	select left('DDC'+cast(h.id as varchar(20)),20) as HeaderId
	FROM tcf.dbo.ddc_header h,
	sf_control_table
	--sf_map_gift
	WHERE h.ddc_header_status_c in (1,3) --current, completed
	and sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_ddc map1 where map1.HeaderId = left('DDC'+cast(h.id as varchar(20)),20))
    and not exists (select 1 from tcf.dbo.ddc_tran where ddc_tran.ddc_header_id = h.id)

	order by 1

end

GO
