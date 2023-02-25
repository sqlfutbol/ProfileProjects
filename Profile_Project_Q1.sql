select *
from ProfileProject..CovidDeaths
order by 3,4

-- Select data that we are going to be using

select  continent
       ,location
       ,date
	   ,total_cases
	   ,new_cases
	   ,total_deaths
	   ,population
from ProfileProject..CovidDeaths
where continent is not null
order by 1,2



-- Total Cases VS Total Deaths
select  continent
       ,location
       ,date
	   ,total_cases
	   ,new_cases
	   ,total_deaths
	   ,(total_deaths/total_cases)*100 as DeathPercentage
from ProfileProject..CovidDeaths
where continent is not null 
order by 1,2


-- Total Cases VS Population
-- Shows what % of population got COVID
select  location
       ,date
	   ,population
	   ,total_cases
	   ,(total_cases/population)*100 as PositivePercentage
from ProfileProject..CovidDeaths
where continent is not null 
order by 1,2

-- What countries have the highest infection rate compared to population

select  continent
       ,location
	   ,population
	   ,MAX(total_cases) as HighestInfectionCount
	   ,(MAX(total_cases)/population)*100 as PositivePercentage
from ProfileProject..CovidDeaths
where continent is not null 
group by continent,location, population
order by PositivePercentage desc

-- Showing countries with highest death count per population

select  continent
       ,location
       ,MAX(cast(total_deaths as int)) as TotalDeathCount
from ProfileProject..CovidDeaths
where continent is not null 
group by continent,location
order by TotalDeathCount desc

-- showing the contintents with highest death count
select  continent
       ,location
       ,MAX(cast(total_deaths as int)) as TotalDeathCount
from ProfileProject..CovidDeaths
where continent is null 
group by continent,location
order by TotalDeathCount desc

-- Highest Death Count Break out by income
select  continent
       ,location
       ,MAX(cast(total_deaths as int)) as TotalDeathCount
from ProfileProject..CovidDeaths
where continent is null 
and location like '%income%'
group by continent,location
order by TotalDeathCount desc




-- global  numbers for new cases/deaths/death %
SELECT date
	   ,SUM(new_cases) as SumTotalCases
	   , SUM(cast(new_deaths as int)) as SumTotalDeaths
	   , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProfileProject..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1 ASC, 4 DESC

-- Global aggregate total of cases/deaths/death %

SELECT SUM(new_cases) as SumTotalCases
	   , SUM(cast(new_deaths as int)) as SumTotalDeaths
	   , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM ProfileProject..CovidDeaths
WHERE continent is not null 


-- Using both tables

select top 1 *
from ProfileProject..CovidVaccinations

-- new vacc and rolling vaccination count
SELECT  cd.continent
      , cd.location
	  , cd.date
	  , cd.population
	  , cv.new_vaccinations
	  , SUM(convert(bigint,cv.new_vaccinations)) OVER(Partition by cd.location order by cd.location, cd.date) as Rolling_Vaccination_count
FROM ProfileProject..CovidDeaths cd
INNER JOIN ProfileProject..CovidVaccinations cv
           on cd.location = cv.location
		   and cd.date = cv.date
WHERE  1=1
AND CD.continent IS NOT NULL
AND CV.continent IS NOT NULL
ORDER BY 1,2,3


-- Using a CTE

WITH New_Vaccinations as (
SELECT  cd.continent
      , cd.location
	  , cd.date
	  , cd.population
	  , CASE 
	        WHEN  cv.new_vaccinations IS NULL THEN 0
			ELSE  CV.new_vaccinations
		END AS New_Vaccinations
	  , SUM(convert(bigint,cv.new_vaccinations)) OVER(Partition by cd.location order by cd.location, cd.date) as Rolling_Vaccination_count
FROM ProfileProject..CovidDeaths cd
INNER JOIN ProfileProject..CovidVaccinations cv
           on cd.location = cv.location
		   and cd.date = cv.date
WHERE  1=1
AND CD.continent IS NOT NULL
AND CV.continent IS NOT NULL
)

SELECT  *
      , (Rolling_Vaccination_count/population) *100 as Rolling_Vaccination_Percentage   
FROM New_Vaccinations



-- Using a Temp Table

DROP Table if Exists #New_Vaccinations
Create Table #New_Vaccinations
(
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population float,
 New_Vaccinations Bigint,
 Rolling_Vaccination_count numeric
)


Insert into #New_Vaccinations
SELECT  cd.continent
      , cd.location
	  , cd.date
	  , cd.population
	  , CASE 
	        WHEN  cv.new_vaccinations IS NULL THEN 0
			ELSE  CV.new_vaccinations
		END AS New_Vaccinations
	  , CASE 
	        WHEN SUM(convert(bigint,cv.new_vaccinations)) OVER(Partition by cd.location order by cd.location, cd.date) is null Then 0
			Else SUM(convert(bigint,cv.new_vaccinations)) OVER(Partition by cd.location order by cd.location, cd.date)
		END as Rolling_Vaccination_count
FROM ProfileProject..CovidDeaths cd
INNER JOIN ProfileProject..CovidVaccinations cv
           on cd.location = cv.location
		   and cd.date = cv.date
WHERE  1=1
AND CD.continent IS NOT NULL
AND CV.continent IS NOT NULL


SELECT  *
      , (Rolling_Vaccination_count/population) *100 as Rolling_Vaccination_Percentage   
FROM #New_Vaccinations






-- Create a view To Store Data for Later Visualizations


Create View New_Vaccinations as 
SELECT  cd.continent
      , cd.location
	  , cd.date
	  , cd.population
	  , CASE 
	        WHEN  cv.new_vaccinations IS NULL THEN 0
			ELSE  CV.new_vaccinations
		END AS New_Vaccinations
	  , CASE 
	        WHEN SUM(convert(bigint,cv.new_vaccinations)) OVER(Partition by cd.location order by cd.location, cd.date) is null Then 0
			Else SUM(convert(bigint,cv.new_vaccinations)) OVER(Partition by cd.location order by cd.location, cd.date)
		END as Rolling_Vaccination_count
FROM ProfileProject..CovidDeaths cd
INNER JOIN ProfileProject..CovidVaccinations cv
           on cd.location = cv.location
		   and cd.date = cv.date
WHERE  1=1
AND CD.continent IS NOT NULL
AND CV.continent IS NOT NULL






select top 1000 *
from New_Vaccinations