USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_hh_accounts_to_delete]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_hh_accounts_to_delete]
AS
begin
	--hh accounts to delete from the maping tables and salesforce
	select Id, SfId from sf_map_hh_account
	where SfId is not null
	and not exists (select 1 from hh_staging
								where hh_staging.CombinedId = sf_map_hh_account.CombinedId)

end
GO
