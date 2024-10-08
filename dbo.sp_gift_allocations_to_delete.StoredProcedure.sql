USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_gift_allocations_to_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_gift_allocations_to_delete]
AS
begin
	--gift allocations to delete from the maping tables and salesforce
	select TranId, SfId from sf_map_gifts_allocations
	where SfId is not null
	and not exists (select 1 	FROM tcf.dbo.trans_action ta
						left join tcf.dbo.cash_trans ct on ta.tran_id = ct.tran_id
						left join tcf.dbo.trade t on ta.tran_id = t.tran_id,
						tcf.dbo.trans_type_c tt,
						tcf.dbo.contribution c
						WHERE ta.trans_type_c = tt.code 
    					and ta.parent_obj_id = c.contrib_id 
    					and tt.name like '%Contr%'
						and ta.trans_status_c <> 7 --exclude cancels
						and ta.trans_type_c <> 611 --skipping multi allocation gifts because there are so few.
					    and cast(ta.tran_id as varchar(20)) = sf_map_gifts_allocations.TranId)

end
GO
