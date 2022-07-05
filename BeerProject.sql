-- Convert columns to float
ALTER TABLE BeerProject..[beer-review-10] ALTER COLUMN beer_abv FLOAT;
ALTER TABLE BeerProject..[beer-review-16] ALTER COLUMN beer_abv FLOAT;

-- Union Tables
DROP TABLE IF EXISTS beer_review;
SELECT a.*
INTO beer_review
FROM BeerProject..[beer-review-1] a
UNION ALL
SELECT b.* FROM BeerProject..[beer-review-2] b
UNION ALL
SELECT c.* FROM BeerProject..[beer-review-3] c
UNION ALL
SELECT d.* FROM BeerProject..[beer-review-4] d
UNION ALL
SELECT e.* FROM BeerProject..[beer-review-5] e
UNION ALL
SELECT f.* FROM BeerProject..[beer-review-6] f
UNION ALL
SELECT g.* FROM BeerProject..[beer-review-7] g
UNION ALL
SELECT h.* FROM BeerProject..[beer-review-8] h
UNION ALL
SELECT i.* FROM BeerProject..[beer-review-9] i
UNION ALL
SELECT j.* FROM BeerProject..[beer-review-10] j
UNION ALL
SELECT k.* FROM BeerProject..[beer-review-11] k
UNION ALL
SELECT l.* FROM BeerProject..[beer-review-12] l
UNION ALL
SELECT m.* FROM BeerProject..[beer-review-12] m
UNION ALL
SELECT n.* FROM BeerProject..[beer-review-13] n
UNION ALL
SELECT o.* FROM BeerProject..[beer-review-14] o
UNION ALL
SELECT p.* FROM BeerProject..[beer-review-15] p
UNION ALL
SELECT q.* FROM BeerProject..[beer-review-16] q;

--Check if the row count match
SELECT COUNT(*)
FROM BeerProject..beer_review;

-- Check for null values
SELECT COUNT(*)-COUNT(brewery_name) As null_brewery_name,
	   COUNT(*)-COUNT(review_overall) As null_review_overall, 
	   COUNT(*)-COUNT(review_aroma) As null_review_aroma,
	   COUNT(*)-COUNT(review_appearance) As null_review_appearance,
	   COUNT(*)-COUNT(beer_style) As null_beer_style,
	   COUNT(*)-COUNT(review_palate) As null_review_palate,
	   COUNT(*)-COUNT(review_taste) As null_review_taste,
	   COUNT(*)-COUNT(beer_name) As null_beer_name,
	   COUNT(*)-COUNT(beer_abv) As null_beer_abv
FROM BeerProject..beer_review; 

-- Fix null values found in the brewery_name column
SELECT *
FROM BeerProject..beer_review
WHERE brewery_name IS NULL;

SELECT *
FROM BeerProject..beer_review
WHERE brewery_id IN (27, 1193);

UPDATE BeerProject..beer_review
SET 
	brewery_name = CASE WHEN brewery_id = '1193' tHEN 'Crailsheimer Engelbräu' 
						WHEN brewery_id = '27' THEN 'Hard Hat American Beer'
						ELSE brewery_name END;

-- fix null values for beer_abv
UPDATE BeerProject..beer_review
SET beer_abv = b.avg_beer_abv
FROM BeerProject..beer_review a
INNER JOIN (
    SELECT beer_style, AVG(beer_abv) AS avg_beer_abv
    FROM BeerProject..beer_review
    GROUP BY beer_style
) b ON a.beer_style = b.beer_style
WHERE beer_abv IS NULL;

-- Get average scores for each brew and count the number of reviews and save in another table
SELECT brewery_name, 
	   beer_name, 
	   beer_style,
	   FORMAT(AVG(review_overall), 'N2') AS review_overall, 
	   FORMAT(AVG(review_aroma), 'N2') AS review_aroma, 
	   FORMAT(AVG(review_appearance), 'N2') AS review_appearance, 
	   FORMAT(AVG(review_palate), 'N2') AS review_palate, 
	   FORMAT(AVG(review_taste), 'N2') AS review_taste, 
	   FORMAT(AVG(beer_abv), 'N2') AS beer_abv, 
	   COUNT(review_overall) AS number_of_reviews
FROM BeerProject..beer_review
GROUP BY brewery_name, beer_name, beer_style
ORDER BY 1;

WITH
  cteBeerReview (brewery_name, beer_name, beer_style, review_overall, review_aroma, review_appearance, review_palate, review_taste, beer_abv, number_of_reviews)
  AS
  (
    SELECT brewery_name, 
		   beer_name, 
		   beer_style,
		   FORMAT(AVG(review_overall), 'N2') AS review_overall, 
		   FORMAT(AVG(review_aroma), 'N2') AS review_aroma, 
		   FORMAT(AVG(review_appearance), 'N2') AS review_appearance, 
		   FORMAT(AVG(review_palate), 'N2') AS review_palate, 
		   FORMAT(AVG(review_taste), 'N2') AS review_taste, 
		   FORMAT(AVG(beer_abv), 'N2') AS beer_abv, 
		   COUNT(review_overall) AS number_of_reviews
	FROM BeerProject..beer_review
	GROUP BY brewery_name, beer_name, beer_style
  )
SELECT COUNT(*)
FROM cteBeerReview 