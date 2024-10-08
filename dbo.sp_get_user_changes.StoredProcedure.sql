SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_user_changes]
AS
begin

	select p.party_id as employee_number,
	substring(i.first_nm, 1, CASE WHEN charindex(' ',i.first_nm) = 0 THEN 100 ELSE charindex(' ',i.first_nm) -1 END) as FirstName,
	rtrim(i.last_nm) as LastName,
	substring(rtrim(i.first_nm) + substring(i.last_nm,len(i.last_nm) -1,1),1,8) as Alias,
	coalesce(coalesce((Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '17' and p.party_id = c.party_id order by c.stamp desc),
			(Select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '30' and p.party_id = c.party_id order by c.stamp desc)),'jmcguire@clevefdn.org') as Email,
	coalesce((select top 1 c.comms_string FROM tcf.dbo.comms c WHERE c.comms_typ_c = '30' and p.party_id = c.party_id order by c.stamp desc),
    lower(left(i.first_nm, 1) + replace(rtrim(i.last_nm),' ',''))  + '@clevefdn.org' )
    as UserName,
	'' as NickName,		
	0 as active,
	'FDNP Standard User' as u_profile, 
	'ISO-8859-1' as EmailEncodingKey,
	'America/New_York' as TimeZoneSidKey,
	'en_US' as LocaleSidKey,
	'en_US' as LanguageLocaleKey,
	0 as crm_content_user,	 
	sf_map_user.SfId,
	'User Upsert' as sf_object
	from tcf.dbo.party_role pr, 
	tcf.dbo.party p,
	tcf.dbo.individual i,
	sf_map_user
	where p.party_id = pr.party_id
	and i.party_id = p.party_id
	and pr.role_type_c = 20 
	and pr.role_status_c = 1
	and (p.loginid not like 'sf_%' AND p.loginid not like '%test%' and p.loginid <> 'sa' and i.first_nm <> 'signer')
	and p.party_id = sf_map_user.PartyId
	and sf_map_user.SfId is null
	order by 1

end

GO
