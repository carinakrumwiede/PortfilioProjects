SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases s Total Deaths
-- shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
AND continent is not null
ORDER BY 1,2


--looking at the total cases vs the population
--shows what percentage of population got Covid
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
ORDER BY 1,2



-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected DESC

--Lets Break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing Countries with Highest Death Count Per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac
--USE CTE




-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated
