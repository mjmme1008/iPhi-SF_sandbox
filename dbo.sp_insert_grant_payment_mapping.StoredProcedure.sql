USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_grant_payment_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_insert_grant_payment_mapping]
AS
begin

	select cast(ta.tran_id as varchar(20)) as Id
	from 
	tcf.dbo.trans_action ta, 
	tcf.dbo.cash_trans ct, 
	tcf.dbo.grantee g,
	sf_control_table
	where trans_type_c in (701,702)
	and ta.tran_id = ct.tran_id
	and ta.parent_obj_id = g.grantee_id
	and sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_grant_payments map1 where map1.Id = cast(ta.tran_id as varchar(20)))
	order by 1

end

GO
