USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_grant_payments_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_grant_payments_delete]
AS
begin
	--grant payments to delete from the maping tables and salesforce
	select Id, SfId from sf_map_grant_payments
	where SfId is not null
	and not exists (select 1 from tcf.dbo.trans_action ta, 
									tcf.dbo.cash_trans ct, 
									tcf.dbo.grantee g
									where trans_type_c in (701,702)
									and ta.tran_id = ct.tran_id
									and ta.parent_obj_id = g.grantee_id
									and cast(ta.tran_id as varchar(20)) = sf_map_grant_payments.Id)

end
GO
