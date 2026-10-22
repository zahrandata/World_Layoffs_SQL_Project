-- Data Cleaning Project

select *
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove any Columns or Row (you sometimes can do this, sometimes you just shouldn't do this)

-- Removing Duplicates

select *
into layoffs_staging
from layoffs; 

select *,
row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, date 
order by company) as row_num
from layoffs_staging
order by row_num;

with duplicate_cte as 
(select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions 
order by company) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

select *
from layoffs_staging
where company = 'Casper';

go
use world_layoff;
with duplicate_cte as 
(
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions 
order by company) as row_num
from layoffs_staging
)
delete
from duplicate_cte
where row_num > 1;

create table layoffs_staging2 (
	company varchar(255), 
	location varchar(255),
	industry varchar(255),
	total_laid_off int null,
	percentage_laid_off varchar(255),
	date varchar(255),
	stage varchar(255),
	country varchar(255),
	funds_raised_millions int null,
	row_num int
);

select *
from layoffs_staging2;

insert into layoffs_staging2
select 
company,
location,
industry,
try_cast(nullif(nullif(total_laid_off, 'NULL'), '') as int),
percentage_laid_off,
date,
stage,
country,
try_cast(nullif(nullif(funds_raised_millions, 'NULL'), '') as int),
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions 
order by company) as row_num
from layoffs_staging;

select *
from layoffs_staging2
where row_num > 1;

-- Standardizing Data

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

select distinct industry
from layoffs_staging2;


select distinct location
from layoffs_staging2
order by 1;

update layoffs_staging2
set location = 'Düsseldorf'
where location = 'Dusseldorf' 

select distinct country
from layoffs_staging2
where country like 'United States%'
order by 1;

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country =  trim(trailing '.' from country)
where country like 'United States%';

update layoffs_staging2
set [date] = NULL
where trim([date]) = '';

update layoffs_staging2
set [date] = convert(varchar(10), try_convert(date, [date], 101), 23) 
where try_convert(date, [date], 101) is not null

select *
from layoffs_staging2

-- NULL or Blank Values

UPDATE layoffs_staging2
SET percentage_laid_off = NULLIF(NULLIF(percentage_laid_off, 'NULL'), ''),
	company = NULLIF(NULLIF(company, 'NULL'), ''),
	[date] = NULLIF(NULLIF([date], 'NULL'), ''),
	[location] = NULLIF(NULLIF([location], 'NULL'), ''),
	country = NULLIF(NULLIF(country, 'NULL'), ''),
	stage = NULLIF(NULLIF(stage, 'NULL'), ''),
	industry = NULLIF(NULLIF(industry, 'NULL'), '');
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null 
or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select t1.industry, t2.industry
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
	and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update t1
set t1.industry = t2.industry
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

select *
from layoffs_staging2
where company like 'Bally%';

-- Remove Columns or Rows

select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * 
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;







