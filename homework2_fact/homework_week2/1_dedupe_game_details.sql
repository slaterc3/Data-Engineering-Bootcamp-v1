-- WEEK 2 Fact Data Modeling: Task 1
-- A query to deduplicate game_details from Day 1 so there's no duplicates

-- CTE will organize according to dupes
-- using ROW_NUMBER() window function
WITH deduped AS (
    SELECT *, 
        -- game_id,
        -- team_id,
        -- player_id,
		-- window function to place duplicates in groups,
		-- then select the first one `row_num = 1`
        ROW_NUMBER() OVER(
			-- dupes defined by having same values for these 3 fields
            PARTITION BY game_id, team_id, player_id
        ) AS row_num
    FROM game_details
)
SELECT *
FROM deduped
WHERE row_num = 1;