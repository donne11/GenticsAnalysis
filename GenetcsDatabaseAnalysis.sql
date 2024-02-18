-- GAD: The Genetic Association Database

use gad;

-- 1. 
-- Explore the content of the various columns in your gad table.
-- List all genes that are "G protein-coupled" receptors in alphabetical order by gene symbol
-- Output the gene symbol, gene name, and chromosome
-- (These genes are often the target for new drugs, so are of particular interest)
-- List all genes that are "G protein-coupled" receptors in alphabetical order by gene symbol
-- Output the gene symbol, gene name, and chromosome

SELECT gene, gene_name, chromosome 
FROM gad
WHERE gene_name = "G protein-coupled receptor" OR gene_name LIKE "%G protein-coupled receptor%"
ORDER BY gene;


-- 2. 
-- How many records are there for each disease class?
-- Output your list from most frequent to least frequent
 -- Count records for each disease class and order by count in descending order
SELECT disease_class, COUNT(*) AS number_of_records
FROM gad
GROUP BY disease_class
ORDER BY number_of_records DESC;


-- 3. 
-- List all distinct phenotypes related to the disease class "IMMUNE"
-- Output your list in alphabetical order

-- List distinct phenotypes related to the disease class "IMMUNE" in alphabetical order
SELECT DISTINCT phenotype
FROM gad
WHERE disease_class = "IMMUNE"
ORDER BY phenotype ASC;


-- 4.
-- Show the immune-related phenotypes
-- based on the number of records reporting a positive association with that phenotype.
-- Display both the phenotype and the number of records with a positive association
-- Only report phenotypes with at least 60 records reporting a positive association.
-- Your list should be sorted in descending order by number of records
-- Use a column alias: "num_records"
SELECT phenotype, COUNT(*) AS num_records
FROM gad
WHERE disease_class = "IMMUNE" AND association = "Y"
GROUP BY phenotype
HAVING num_records > 59
ORDER BY num_records DESC;


-- 5.
-- List the gene symbol, gene name, and chromosome attributes related
-- to genes positively linked to asthma (association = Y).
-- Include in your output any phenotype containing the substring "asthma"
-- List each distinct record once
-- Sort gene symbol
SELECT DISTINCT gene AS gene_symbol, gene_name, chromosome
FROM gad
WHERE association = "Y" AND (phenotype = "Asthma" OR phenotype LIKE "%Asthma%")
ORDER BY gene_symbol;


-- 6. 
-- For each chromosome, over what range of nucleotides do we find
-- genes mentioned in GAD?
-- Exclude cases where the dna_start value is 0 or where the chromosome is unlisted.
-- Sort your data by chromosome. Don't be concerned that
-- the chromosome values are TEXT. (1, 10, 11, 12, ...)
SELECT chromosome, MIN(dna_start), MAX(dna_end)
FROM gad
WHERE (chromosome IS NOT NULL AND dna_start > 0)
GROUP BY chromosome
ORDER BY CAST(chromosome AS SIGNED);


-- 7 
-- For each gene, what is the earliest and latest reported year
-- involving a positive association
-- Ignore records where the year isn't valid. (Explore the year column to determine what constitutes a valid year.)
-- Output the gene, min-year, max-year, and number of GAD records
-- order from most records to least.
-- Columns with aggregation functions should be aliased
SELECT gene, MIN(year), MAX(year), COUNT(*)
FROM gad
WHERE year IS NOT NULL AND (year > 0) AND (association = "Y")
GROUP BY gene
ORDER BY COUNT(*) DESC;


-- 8. 
-- Which genes have a total of at least 100 positive association records (across all phenotypes)?
-- Give the gene symbol, gene name, and the number of associations
-- Use a 'num_records' alias in your query wherever possible
SELECT gene, gene_name, COUNT(*) AS num_records
FROM gad
WHERE association = "Y"
GROUP BY gene, gene_name
HAVING COUNT(*) > 99
ORDER BY num_records DESC;


-- 9. 
-- How many total GAD records are there for each population group?
-- Sort in descending order by count
-- Show only the top five results based on number of records
-- Do NOT include cases where the population is blank
SELECT population, COUNT(*) AS number_of_records
FROM gad
WHERE population IS NOT NULL AND population != ""
GROUP BY population
ORDER BY number_of_records DESC
LIMIT 5;


-- 10. 
-- In question 5, we found asthma-linked genes
-- But these genes might also be implicated in other diseases
-- Output gad records involving a positive association between ANY asthma-linked gene and ANY disease/phenotype
-- Sort your output alphabetically by phenotype
-- Output the gene, gene_name, association (should always be 'Y'), phenotype, disease_class, and population
-- Hint: Use a subselect in your WHERE class and the IN operator
SELECT gene, gene_name, "Y" AS association, phenotype, disease_class, population
FROM gad
WHERE gene IN (
SELECT DISTINCT gene
FROM gad
WHERE (phenotype = "Asthma" OR phenotype LIKE "%Asthma%")) AND association = "Y"
ORDER BY phenotype;


-- 11. 
-- Modify your previous query.
-- Let's count how many times each of these asthma-gene-linked phenotypes occurs
-- in our output table produced by the previous query.
-- Output just the phenotype, and a count of the number of occurrences for the top 5 phenotypes
-- with the most records involving an asthma-linked gene (EXCLUDING asthma itself).
SELECT phenotype, COUNT(*) AS number_of_phenotypes
FROM (SELECT gene, gene_name, "Y" AS association, phenotype, disease_class, population
FROM gad
WHERE gene IN (
SELECT DISTINCT gene
FROM gad
WHERE (phenotype = "Asthma" OR phenotype LIKE '%Asthma%')) AND association = 'Y') 
AS asthma_records
WHERE phenotype != "Asthma"
GROUP BY phenotype
ORDER BY number_of_phenotypes DESC
LIMIT 5;


-- 12. 
-- Interpret your analysis

-- a) Search the Internet. Does existing biomedical research support a connection between asthma and the
-- top phenotype you identified above? Cite some sources and justify your conclusion!
/*
The results of the meta-analysis do, in fact, suggest a possible link between Type 1 diabetes 
and asthma. A more thorough investigation, which included adjusted odds ratios and cohort studies, 
indicated a relationship even though the prior evaluation appeared to show no association. 
The risk of eventually acquiring Type 1 diabetes was found to be greater in people 
who were been diagnosed with asthma in the past. The risk of getting diabetes was increased 
when asthma appeared before the onset of type 1 diabetes. However, these findings highlight 
the need for more study to properly evaluate the link between asthma and type 1 diabetes.

Citations
Metsälä, Johanna, et al. “The Association between Asthma and Type 1 Diabetes: A Paediatric Case-Cohort Study in Finland, 
Years 1981–2009.” International Journal of Epidemiology, vol. 47, no. 2, 2 Dec. 2017, pp. 409–416, 
https://doi.org/10.1093/ije/dyx245. Accessed 26 Jan. 2021.

Zeng, Rong, et al. “Type 1 Diabetes and Asthma: A Systematic Review and Meta-Analysis of Observational Studies.” 
Endocrine, vol. 75, no. 3, 14 Jan. 2022, pp. 709–717, https://doi.org/10.1007/s12020-021-02973-x. Accessed 3 Oct. 2023.

*/

-- b) Why might a drug company be interested in instances of such "overlapping" phenotypes?
/*

Aside from wanting to be competitive and make money a drrug company would care to understand 
the effectiveness of medication can be increased by providing more robst forms of  treatments 
for such medical disorders. In this case, a drug that addresses both type 1 diabetes and asthma 
could provide better outcomes for those with both conditions. This could then minimize the need for 
various medications and lessen effects.

*/


-- CONGRATULATIONS!!: YOU JUST DID SOME LEGIT DRUG DISCOVERY RESEARCH! :-)

