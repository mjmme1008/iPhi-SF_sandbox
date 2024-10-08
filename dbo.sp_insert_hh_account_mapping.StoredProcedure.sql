USE [SFdb_sandbox]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_hh_account_mapping]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_insert_hh_account_mapping]
AS
BEGIN

	DECLARE @HhId varchar(20)
	DECLARE @PartyId1 int
	DECLARE @PartyId2 int
	DECLARE @Party1Count int
	DECLARE @Party2Count int
	DECLARE @HhCount int
	DECLARE @ExistingPartyId2 int
	DECLARE @DeleteDate date
	DECLARE @MergeDate date
	DECLARE @CombinedId varchar(100)
	DECLARE @ExistingCombinedId varchar(100)
	DECLARE @ExistingCombinedIdParty2 varchar(100)
	DECLARE @ExistingParty1HhId varchar(20)
	DECLARE @ExistingParty2HhId varchar(20)
	DECLARE @SfIdToDelete varchar(20)
	DECLARE @SfIdToKeep varchar(20)

	DECLARE @cHh CURSOR

	SET @cHh = CURSOR dynamic  FOR 
	SELECT rtrim(CombinedId),
	Partyid1,
	PartyId2
	FROM hh_staging
	--where partyid1 = 26439 OR PartyId2 = 13132  
	ORDER BY Partyid1

	OPEN @cHh
	FETCH NEXT FROM @cHh INTO @CombinedId, @PartyId1, @PartyId2
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN


		--See if party1 is already in the hh map table
		SELECT @Party1Count = count(*), @ExistingCombinedId = CombinedId, @ExistingParty1HhId = HhId
		FROM sf_map_hh_account 
		WHERE PartyId = @PartyId1
		group by CombinedId, HhId

		IF @Party1Count is null
		begin
			SET @Party1Count = 0
		end

		--See if party2 is already in the hh map table
		SELECT @Party2Count = count(*), @ExistingCombinedIdParty2 = CombinedId, @ExistingParty2HhId = HhId
		FROM sf_map_hh_account 
		WHERE PartyId = @PartyId2
		group by CombinedId, HhId

		IF @Party2Count is null
		begin
			SET @Party2Count = 0
		end

		IF @Party1Count = 0 AND @Party2Count = 0 
			BEGIN
				--Get the next hh id
				SELECT @HhId = 'H' + cast(id + 1 as varchar(20)) from next_hh_id
				--update the next hh id table
				UPDATE next_hh_id set id = cast(substring(@HhId,2,20) as int)

				INSERT INTO sf_map_hh_account (HhId, PartyId, SfId, CombinedId, DeleteDate, MergeDate )
				VALUES (@HhId,@PartyId1,null,@CombinedId,null,null)
			END

		ELSE 

		IF @CombinedId <> @ExistingCombinedId OR @CombinedId <> @ExistingCombinedIdParty2
			--some aspect of the parties have changed in the household.
			BEGIN

				IF @Party1Count > 0
				BEGIN
					--if the combined id has changed update the combined id for the partyid1 record.
					UPDATE sf_map_hh_account 
					set CombinedId = @CombinedId
					WHERE PartyId = @PartyId1
				END

				ELSE
				BEGIN
					--insert party1 HH account record
					INSERT INTO sf_map_hh_account (HhId, PartyId, SfId, CombinedId, DeleteDate, MergeDate )
					VALUES (@ExistingParty2HhId,@PartyId1,null,@CombinedId,null,null)
				END


				/*--see if there was a partyid2 for the existing cominbined id in the mapping table, update it to the new combined id.
				IF @PartyId2 > 0
					BEGIN
			
						SELECT @ExistingPartyId2 = PartyId
						FROM sf_map_hh_account
						WHERE PartyId = @PartyId2

						UPDATE sf_map_hh_account
						set CombinedId = @CombinedId
						WHERE CombinedId = @ExistingCombinedIdParty2
						AND PartyId = @ExistingPartyId2

					END*/

				-- 2 parties being combined into one household
				print 'A'
				print @PartyId2
				print @CombinedId
				print @ExistingCombinedIdParty2
				IF @PartyId2 > 0 AND @CombinedId <> @ExistingCombinedIdParty2 AND @Party2Count > 0 
					BEGIN
						print 'B'
						print @Party1Count
						IF @Party1Count > 0 
						BEGIN
							SELECT @SfIdToDelete = SfId from sf_map_hh_account where CombinedId = @ExistingCombinedIdParty2
							SELECT @SfIdToKeep = SfId from sf_map_hh_account where HhId = @ExistingParty1HhId and PartyId = @PartyId1
							--insert new household for party2
							INSERT INTO sf_map_hh_account (HhId, PartyId, SfId, CombinedId, DeleteDate, MergeDate )
							VALUES (@ExistingParty1HhId,@PartyId2,@SfIdToKeep,@CombinedId,null,CURRENT_TIMESTAMP)

							SELECT @HhCount = count(*) from sf_map_hh_account where CombinedId = @ExistingCombinedIdParty2
							IF @HhCount = 1
							BEGIN
								--insert delete/merge record for hh acount to merge/delete
								INSERT INTO sf_accounts_to_merge values (@SfIdToDelete, @SfIdToKeep, 0,null)
							END
						END
						ELSE
						BEGIN
							--insert new household for party2
							INSERT INTO sf_map_hh_account (HhId, PartyId, SfId, CombinedId, DeleteDate, MergeDate )
							VALUES (@ExistingParty2HhId,@PartyId2,null,@CombinedId,null,null)
						END

						--delete old household account record.
						DELETE FROM sf_map_hh_account WHERE PartyId = @PartyId2 AND CombinedId <> @CombinedId
					END

				-- if @PartyId2 is null and it exists in the mapping table with the existing combinedid, delete the partyid2 record from the mapping table.
				print 'C'
				print @PartyId2
				IF @PartyId2 = 0
					BEGIN
			
						SELECT @ExistingPartyId2 = PartyId
						FROM sf_map_hh_account
						WHERE PartyId <> @PartyId1
						AND Combinedid = @ExistingCombinedId

						DELETE from sf_map_hh_account
						WHERE CombinedId = @ExistingCombinedId
						AND PartyId = @ExistingPartyId2

					END

			END
		print 'D'
		print @PartyId2
		IF @PartyId2 > 0
			BEGIN
				print 'E'
				print @Party2Count
				IF @Party2Count = 0 
					BEGIN
						print 'F'
						print @HhId
						IF @HhId = '' OR @HhId is null
							BEGIN
								--get the existing hh id from party1
								SELECT @HhId = HhId FROM sf_map_hh_account where PartyId = @PartyId1
							END
						INSERT INTO sf_map_hh_account (HhId, PartyId, SfId, CombinedId, DeleteDate, MergeDate )
						VALUES (@HhId,@PartyId2,null,@CombinedId,null,null)

						--delete any parties from this household that are no longer in it.
						DELETE FROM sf_map_hh_account where combinedid = @ExistingCombinedId and partyid <> @PartyId1 and PartyId <> @PartyId2
					END
			END

		SET @Party1Count = 0
		SET @Party2Count = 0
		SET @HhCount = 0
		SET @ExistingPartyId2 = 0
		SET @ExistingParty1HhId = 0
		SET @ExistingParty2HhId = 0
		SET @HhId = ''
		SET @ExistingCombinedId = ''
		SET @ExistingCombinedIdParty2 = ''
		SET @SfIdToDelete = ''
		SET @SfIdToKeep = ''

		FETCH NEXT FROM @cHh INTO @CombinedId, @PartyId1, @PartyId2
	END

	CLOSE @cHh
	DEALLOCATE @cHh

END

GO
