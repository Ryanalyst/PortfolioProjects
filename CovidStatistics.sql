
SELECT *
  FROM CovidDeaths
  --WHERE continent is not null
  ORDER BY 3,4;

  --SELECT *
  --FROM PortfolioProject.dbo.CovidVaccinations
  --ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths
FROM CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States
SELECT Location, date, total_cases, total_deaths, 
ROUND((CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT)*100),2) AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;


SELECT location, date, total_cases, total_deaths
FROM CovidDeaths


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, Population, total_cases, (total_cases/population)*100 As CovidPercentage
FROM CovidDeaths
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 As PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;


-- Showing Countries with the highest death count per population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Let's break things down by continent

--Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- Global numbers

SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(New_deaths)/SUM(New_Cases)*100 as 
DeathPercentage
FROM CovidDeaths
WHERE continent is not null AND new_cases > 0
ORDER BY 1,2;

-- Global numbers per day

SELECT date, SUM(new_cases) as Total_Cases, 
		SUM(new_deaths) as Total_Deaths, 
		ROUND(SUM(New_deaths)/SUM(New_Cases)*100,2) as DeathPercentage
FROM CovidDeaths
WHERE continent is not null AND new_cases > 0
GROUP BY date
ORDER BY 1,2;


-- Look at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population) *100
FROM CovidDeaths dea
Join [CovidVaccinations] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.location = 'United States'
ORDER BY 2,3

--USE CTE

WITH PopvsDeath (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinePercentage
FROM PopvsVac;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_vaccines bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) as total_vaccines
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

Select location, population, SUM(Total_vaccines) total_vaccines
From #PercentPopulationVaccinated
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY total_vaccines desc


-- Creating View to store data for later visualizations
Drop view if exists PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population) *100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null)
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated

-- Showing the percentage of the population that received the vaccination per country

Select vac.location, dea.population, MAX(cast(vac.people_vaccinated as bigint))
as TotalVaccinated,
MAX((vac.people_vaccinated/dea.population))*100 as VaccinePercentage
From CovidVaccinations vac
JOIN CovidDeaths dea ON 
vac.location = dea.location AND vac.date = dea.date
WHERE  vac.continent is not null
GROUP BY vac.location, dea.population
Order By VaccinePercentage desc

Select *
from CovidVaccinations;

-- Showing the amount of vaccinations per continent
DROP VIEW IF EXISTS PopVSVac;

CREATE VIEW PopVSVac as
(SELECT  location, population, 
MAX(cast(people_vaccinated as bigint)) as total_vac,
ROUND(MAX(cast(people_vaccinated as bigint))/MAX(population) * 100,2)
as percent_vaccinated
FROM CovidVaccinations
where continent is null
GROUP BY location, population);

SELECT *
FROM PopVSVac
ORDER BY total_vac desc;


-- Life expectancy by country
Select location, gdp_per_capita, ROUND(AVG(life_expectancy), 2) as Life_expentancy
from CovidVaccinations
where location <> continent AND life_expectancy is NOT NULL AND gdp_per_capita IS NOT NULL
GROUP BY location, gdp_per_capita
ORDER BY gdp_per_capita;

Select location, gdp_per_capita, ROUND(AVG(life_expectancy), 2) as Life_expentancy
from CovidVaccinations
where location <> continent AND life_expectancy is NOT NULL AND gdp_per_capita IS NOT NULL
GROUP BY location, gdp_per_capita
ORDER BY Life_expentancy

-- New vaccinations per day in the United States
select location, date, new_vaccinations
from CovidVaccinations
where location = 'United States' and new_vaccinations IS NOT NULL
