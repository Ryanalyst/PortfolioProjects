
SELECT TOP (1000) *
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE continent is not null
  ORDER BY 3,4;

  --SELECT *
  --FROM PortfolioProject.dbo.CovidVaccinations
  --ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, Population, total_cases, (total_cases/population)*100 As CovidPercentage
FROM PortfolioProject..CovidDeaths
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
FROM PortfolioProject..CovidDeaths
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

SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(New_deaths)/SUM(New_Cases)*100 as 
DeathPercentage
FROM CovidDeaths
WHERE continent is not null AND new_cases > 0
GROUP BY date
ORDER BY 1,2;


-- Lookat at Total Population vs Vaccinatin

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population) *100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population) *100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population) *100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population) *100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated
