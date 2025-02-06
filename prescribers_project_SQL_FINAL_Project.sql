-- 1a. Which prescriber had the highest total number of claims
-- (totaled over all drugs)? Report the npi and the total number of claims.

SELECT *
FROM prescriber;

SELECT DISTINCT script.npi, person.nppes_provider_last_org_name, SUM (script.total_claim_count) AS claim_count
FROM prescription as script
INNER JOIN prescriber as person
ON script.npi = person.npi
GROUP BY script.npi, person.nppes_provider_last_org_name
ORDER BY claim_count DESC;

-- TOMMY REVIEW
SELECT npi,
		SUM(total_claim_count) as total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;

-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, 
-- specialty_description, and the total number of claims.

SELECT DISTINCT script.npi, person.nppes_provider_last_org_name, person.nppes_provider_first_name, person.specialty_description, SUM (script.total_claim_count) AS claim_count
FROM prescription as script
INNER JOIN prescriber as person
ON script.npi = person.npi
GROUP BY script.npi, person.nppes_provider_last_org_name, person.nppes_provider_first_name, person.specialty_description
ORDER BY claim_count DESC;

--TOMMY REVIEW
SELECT nppes_provider_first_name,
		nppes_provider_last_org_name,
		specialty_description,
		SUM(total_claim_count) as total_claims
FROM prescription
INNER JOIN prescriber
USING (npi)
GROUP BY nppes_provider_first_name,
		nppes_provider_last_org_name,
		specialty_description
ORDER BY total_claims DESC;

-- We don't have to use an alias for columns that don't share names

-- 2a. Which specialty had the most total number of claims 
-- (totaled over all drugs)?

SELECT p.specialty_description, SUM(script.total_claim_count) as total_claims
FROM prescriber as p
INNER JOIN prescription as script
ON p.npi = script.npi
GROUP BY p.specialty_description
ORDER BY total_claims DESC;


-- TOMMY REVIEW

SELECT specialty_description,
		SUM(total_claim_count) as total_claims
FROM prescriber
INNER JOIN prescription 
USING (npi)
GROUP BY specialty_description
ORDER by total_claims DESC;




-- 2b. Which specialty had the most total number of claims for opioids?

SELECT SUM(rx.total_claim_count) AS max_claims,
		dr.specialty_description
FROM prescription AS rx
INNER JOIN prescriber AS dr
ON rx.npi = dr.npi
INNER JOIN drug
ON rx.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY dr.specialty_description
ORDER BY max_claims DESC;

-- TOMMY REVIEW
SELECT specialty_description
		SUM(total_claim_count) as total_claims
FROM prescriber
INNER JOIN prescription USING (npi)
INNER JOIN drug USING (drug_name)
WHERE opioid_drug_flag ='Y'
GROUP BY specialty_description 
ORDER BY total_claims DESC;


--Brenna's Scratch Attempts
SELECT drug_name, total_claim_count
FROM prescription
WHERE drug_name = 


SELECT p.specialty_description, script.drug_name, SUM (script.total_claim_count) as total_claims
FROM prescriber as p
INNER JOIN prescription as script
ON p.npi = script.npi
WHERE script.drug_name = 'opioid'
GROUP BY p.specialty_description, script.drug_name;


SELECT drug_name, opioid_drug_flag, long_acting_opioid_drug_flag
FROM drug
WHERE opioid_drug_flag = 'Y'
	AND long_acting_opioid_drug_flag = 'Y'
	
SELECT *
FROM prescriber;


-- *2c. Challenge Question: Are there any specialties that appear in the prescriber 
-- table that have no associated prescriptions in the prescription table?

SELECT specialty_description,
		SUM(total_claim_count) as total_claims
FROM prescriber
LEFT JOIN prescription USING (npi)
GROUP BY specialty_description 
HAVING SUM(total_claim_count) IS NULL;

-- *2d. Difficult Bonus: Do not attempt until you have solved all other problems! 
-- For each specialty, report the percentage of total claims by that specialty 
-- which are for opioids. Which specialties have a high percentage of opioids?

SELECT
	specialty_description,
	-- total of opioid prescribed / total claims
	ROUND((SUM (CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END)/SUM(total_claim_count) * 100),2) AS percent_opioid_claims
FROM prescriber
LEFT JOIN prescription USING (npi)
LEFT JOIN drug USING (drug_name)
GROUP BY specialty_description
ORDER BY percent_opioid_claims DESC NULLS LAST;



-- 3a. Which drug (generic_name) had the highest total drug cost?

SELECT d.generic_name, d.drug_name, MAX(p.total_drug_cost) AS max_drug_cost
FROM drug as d
INNER JOIN prescription as p
ON d.drug_name = p.drug_name
GROUP BY d.generic_name, d.drug_name
ORDER BY max_drug_cost DESC;

--TOMMY REVIEW

SELECT generic_name,
		SUM(total_drug_cost)::MONEY AS total_cost
FROM drug
INNER JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC;



-- b. Which drug (generic_name) has the hightest total cost per day?
-- Bonus: Round your cost per day column to 2 decimal places. 
-- Google ROUND to see how this works.

SELECT d.generic_name, d.drug_name, ROUND(MAX(p.total_drug_cost)/ p.total_day_supply, 2) AS max_drug_cost
FROM drug as d
INNER JOIN prescription as p
ON d.drug_name = p.drug_name
GROUP BY d.generic_name, d.drug_name, p.total_day_supply
ORDER BY max_drug_cost DESC;

--TOMMY REVIEW

SELECT generic_name,
		ROUND(SUM(total_drug_cost)/ SUM(total_day_supply), 2) AS total_cost
FROM drug
INNER JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC;

-- TARIK ANSWER

SELECT generic_name, ROUND((SUM(total_drug_cost) / prescription.total_day_supply),2) AS max_cost_per_day
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY generic_name, prescription.total_day_supply
ORDER BY max_cost_per_day DESC;

-- 4a. For each drug in the drug table, return the drug name and then a column 
-- named 'drug_type' which says 'opioid' for drugs which 
-- have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have 
-- antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. 
--Hint: You may want to use a CASE expression for this.


SELECT drug_name,
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type	
FROM drug;	

--TOMMY REVIEW

SELECT drug_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type
FROM drug
ORDER BY drug_type ASC;	

--4b. Building off of the query you wrote for part a, determine whether more was 
--spent (total_drug_cost) on opioids or on antibiotics. 
-- Hint: Format the total costs as MONEY for easier comparision.

--TOMMY REVIEW

SELECT
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type,
	SUM(total_drug_cost)::MONEY AS total_cost
FROM drug
INNER JOIN prescription USING (drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;

--Brenna's Answer

WITH opiod_antibiotic_spend AS
(SELECT d.drug_name, SUM(p.total_drug_cost) AS total_spent,
	CASE 
		WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type
FROM drug as d
INNER JOIN prescription as p
ON d.drug_name = p.drug_name
GROUP BY d.drug_name, d.opioid_drug_flag, d.antibiotic_drug_flag
)
SELECT SUM()

-- EMILY FORMULA

WITH aandocost AS
			(
	SELECT d.drug_name,
		CASE
			  WHEN d.opioid_drug_flag = 'Y' THEN 'O'
			  WHEN d.antibiotic_drug_flag = 'Y' THEN 'A'
			  ELSE NULL
			END AS drug_type,
		sum(p.total_drug_cost) AS total_cost
	from drug as d
	inner join prescription as p
	USING (drug_name)
	GROUP BY  drug_type, d.drug_name
	ORDER BY drug_type, sum(p.total_drug_cost)
			)
SELECT sum(total_cost) AS spending, drug_type
FROM aandocost
WHERE drug_type = 'O' OR drug_type = 'A'
GROUP BY drug_type

-- 5a. How many CBSAs are in Tennessee? 
-- Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT cbsaname
FROM cbsa
WHERE RIGHT (cbsaname, 2) = 'TN';

-- TOMMY REVIEW

SELECT COUNT(DISTINCT cbsa)
FROM cbsa
INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';



-- 5b. Which cbsa has the largest combined population? 
-- Which has the smallest? Report the CBSA name and total population.

SELECT DISTINCT c.cbsaname, SUM(p.population) as max_pop
FROM population as p
INNER JOIN cbsa as c
ON p.fipscounty = c.fipscounty
GROUP BY c.cbsaname
ORDER BY max_pop DESC;

-- TOMMY REVIEW
SELECT
	cbsaname,
	SUM(population) AS total_pop
FROM cbsa
INNER JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_pop DESC;


--5c. What is the largest (in terms of population) county which is not included 
-- in a CBSA? Report the county name and population.

SELECT population.fipscounty as pop, 
		fips_county.county as county, 
		cbsa.fipscounty as cbsa,
		MAX(population.population)
FROM population
JOIN fips_county
ON population.fipscounty = fips_county.fipscounty
JOIN cbsa
ON cbsa.fipscounty = population.fipscounty
GROUP BY population.fipscounty, fips_county.county, cbsa.fipscounty
ORDER BY pop DESC;

--TOMMY REVIEW

SELECT county, population
FROM fips_county
INNER JOIN population USING (fipscounty)
WHERE fipscounty NOT IN (SELECT fipscounty FROM cbsa);

-- 6a. Find all rows in the prescription table where total_claims is at least 3000.
-- Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

-- 6b. For each instance that you found in part a, add a column that indicates
-- whether the drug is an opioid.

SELECT p.drug_name, p.total_claim_count,
	CASE
		WHEN d.opioid_drug_flag = 'Y' THEN 'Yes'
		ELSE 'No'
	END AS is_opioid
FROM prescription as p
INNER JOIN drug as d
ON p.drug_name = d.drug_name
WHERE p.total_claim_count >= 3000;

--TOMMY REVIEW

SELECT drug_name,
	total_claim_count,
	opioid_drug_flag
FROM prescription
INNER JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000;

-- Didn't Work
WITH 3000_clams AS
(
SELECT drug_name, total_claim_count
FROM prescription as p
WHERE total_claim_count >= 3000
)
SELECT drug
ON p.drug_name = d.drug_name
WHERE opioid_drug_flag = 'Y' AS "opioid"
GROUP BY drug_name, total_claim_count;


-- 6c. Add another column to you answer from the previous part which gives 
-- the prescriber first and last name associated with each row.

--TOMMY REVIEW

SELECT
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	drug_name,
	total_caim_count,
	opioid_drug_flag
FROM prescription
INNER JOIN drug USING (drug_name)
INNER JOIN prescriber USING (npi)
WHERE total_claim_count >= 3000;

-- BRENNA'S ANSWER

SELECT  pr.nppes_provider_last_org_name, pr.nppes_provider_first_name, p.drug_name, p.total_claim_count,
	CASE
		WHEN d.opioid_drug_flag = 'Y' THEN 'Yes'
		ELSE 'No'
	END AS is_opioid
FROM prescription as p
INNER JOIN drug as d
ON p.drug_name = d.drug_name
INNER JOIN prescriber as pr
ON pr.npi = p.npi
WHERE p.total_claim_count >= 3000;


-- 7a. First, create a list of all npi/drug_name combinations for pain 
-- management specialists (specialty_description = 'Pain Management) in the city 
-- of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an 
-- opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. 
--You will only need to use the prescriber and drug tables since you don't 
-- need the claims numbers yet.

SELECT pr.npi, d.drug_name
FROM prescriber as pr
JOIN prescription as p
ON pr.npi = p.npi
JOIN drug as d
ON p.drug_name = d.drug_name
WHERE pr.specialty_description = 'Pain Management'
AND pr.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y';

--TOMMY REVIEW

SELECT *
FROM prescriber
CROSS JOIN drug
INNER JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y';

-- 7b. Next, report the number of claims per drug per prescriber. 
-- Be sure to include all combinations, whether or not the prescriber had any claims. 
-- You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT prescription.total_claim_count, 
		prescription.drug_name, 
		prescriber.nppes_provider_last_org_name
	FROM prescription
	JOIN prescriber
	ON prescription.npi = prescriber.npi;

--TOMMY REVIEW
SELECT npi, drug.drug_name, total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y';


-- 7c. Finally, if you have not done so already, fill in any missing values for
-- total_claim_count with 0. Hint - Google the COALESCE function.

SELECT prescription.total_claim_count, 
		prescription.drug_name, 
		prescriber.nppes_provider_last_org_name,
		COALESCE(prescription.total_claim_count, 0) AS no_claims
	FROM prescription
	JOIN prescriber
	ON prescription.npi = prescriber.npi
	ORDER BY no_claims ASC;

--TARIK FORMULA

WITH pain_mgmt AS (
SELECT npi, drug.drug_name

--TOMMY REVIEW
SELECT npi, drug.drug_name,
		COALESCE(total_claim_count, 0) AS total_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
ORDER BY total_claims DESC;