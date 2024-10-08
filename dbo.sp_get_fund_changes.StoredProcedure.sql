SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_get_fund_changes]
AS
begin

	select 
    a.acct_id as ExtSysId__c, 
	substring(a.acct_nm,1,80) as Name,
	substring(a.acct_nm,1,255) as FundName__c,
	substring(a.acct_sh_nm,1,100) as FundNameShort__c,
	cast(Coalesce(d.establish_d, a.open_d) as date) as DateEstablished__c,
	(select c.name from tcf.dbo.acct_class_c c where c.code = a.acct_class_c) as FundClass__c,
	CASE WHEN a.list_publicly_f = 1 THEN 'True' ELSE 'FALSE' END as ListPublicly__c,
	CASE WHEN a.exclude_f = 'Y' THEN 'True' ELSE 'FALSE' END as ExcludeAnnualReport__c,
	CASE WHEN a.anonym_internet_f = 'Y' THEN 'True' ELSE 'FALSE' END as ShowOnDonorView__c,
	CASE WHEN a.beclosed_f = 1 THEN 'True' ELSE 'FALSE' END as ToBeClosed__c,
	CASE WHEN a.givin_opportun_f = 1 THEN 'True' ELSE 'FALSE' END as GivingOpportunities__c,
	CASE WHEN d.anonym_grant_f = 'Y' THEN 'True' ELSE 'FALSE' END as AnonymousGrants__c,
	CASE WHEN d.show_recommender_address_f = 'Y' THEN 'True' ELSE 'FALSE' END as ShowRecommenderAddress__c,
	CASE WHEN d.show_recommender_name_f = 'Y' THEN 'True' ELSE 'FALSE' END as ShowRecommenderName__c,
	a.acct_descr as npsp__Description__c,
	a.special_handling_grants as SpecialHandlingGrants__c,
	(select t.name from tcf.dbo.tier_c t where t.code = a.tier_c) as Tier__c,
	a.spechand_memo as Comments__c,
	a.est_gift_amt as FirstGiftAmount__c,
	--FimsF.SubType as SubType__c,
	(select t.name from tcf.dbo.acct_type_c t where t.code = a.acct_type_c) as FundType__c,
	--(select i.name from tcf.dbo.interest_restriction_c i where i.code = a.interest_restriction_c) as InterestCode__c,
	--FimsF.divdescr as DivisionCode__c,
	--FimsF.Soudescr as SourceCode__c,
	coalesce((select top 1 sf_map_user.SfId
		from tcf.dbo.interested_party ip, sf_map_user
		where ip.party_id = sf_map_user.PartyId
		and ip.acct_role_c = 191
		and ip.iparty_status_c = 1
		and ip.acct_id = a.acct_id order by ip.party_id),'0054P000009tKZEQA2') as OwnerId,
	cast(a.close_d as date) as DateTerminated__c,
	--FimsF.Spechandling as fdnp_crm__SpecialHandling__c,
	--FimsF.fndackcomment as fdnp_crm__FundDescription__c, 
	--FimsF.fndgiftlang as fdnp_crm__GiftLanguage__c,
	b.purpose as Purpose__c,
	--FimsF.fndyrbook as fdnp_crm__AnnualReportDesc__c,
	--case when a.acct_status_c = 1 then 'True' else 'False' end as npsp__Active__c,
	CASE WHEN a.acct_status_c = 1 THEN 'True' ELSE 'False' END as npsp__Active__c,
    a2.AccountMarketValue as MarketValue__c,
    convert(date,GETDATE()) as MarketValueAsOfDate__c,
    a2.SpendBalance as AvailableToSpend__c,
	--FimsF.endowment as fdnp_crm__Endowment__c,
	--FimsF.PrinAccess as fdnp_crm__PrincipalAccess__c,
	sf_map_fund.SfId,
	'Fund Upsert' as sf_object
	from
	sf_control_table,
	sf_map_fund,
	tcf.dbo.account a
	left outer join tcf.dbo.dfund d on d.dfund_id = a.acct_id
	left outer join tcf.dbo.bequest b on b.acct_id = a.acct_id
    left outer join rpttest.dbo.Account01 a2 on a.acct_id=a2.AccountID
	where a.acct_type_c <> 1
	and dbo.fn_stampdatetime(a.stamp) >= sf_control_table.last_load_date
	and dbo.fn_stampdatetime(a.stamp) <= sf_control_table.start_load_date
	and sf_control_table.source_object = 'IPHISync'
	and a.acct_id = sf_map_fund.AcctId
	and a.acct_status_c <> 3
    and a.acct_type_c <> 1      --Not an Account
	order by 1

end
GO
