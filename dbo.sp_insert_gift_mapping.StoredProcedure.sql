SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insert_gift_mapping]
AS
begin

	select cast(ta.tran_id as varchar(20)) as TranId
	FROM tcf.dbo.trans_action ta
	left join tcf.dbo.cash_trans ct on ta.tran_id = ct.tran_id
	left join tcf.dbo.trade t on ta.tran_id = t.tran_id,
	tcf.dbo.trans_type_c tt,
	tcf.dbo.contribution c,
	sf_control_table
	WHERE ta.trans_type_c = tt.code 
    	and ta.parent_obj_id = c.contrib_id 
	-- and ta.trans_status_c <> 7 --exclude cancels
	and ta.trans_type_c in (601, 602) --only include these gift types for now
	and ta.trans_status_c = case when ta.trans_type_c = 601 then  10 else 11 end --2/9/2024 only include posted; 5/17/2024 - include received for security gifts
	--code	name
--601	Cash Contrib    
--602	Sec Contrib     
--611	Multi-Acct Contr
--612	Complex Contrib 
--613	Bulk Cash Contr 
--621	DAG Contrib     
--622	Volunt. Contrib 
--699	Recurring Contri
--901	Contrib Adm Fee 
	and sf_control_table.source_object = 'IPHISync'
	and not exists (select 1 from sf_map_gifts map1 where map1.TranId = cast(ta.tran_id as varchar(20)))
	order by 1

end

GO
