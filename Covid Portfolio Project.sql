select *
from PortfolioProject..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


--TOTAL CASES VS TOTAL DEATHS IN PERCENTAGE

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As percenatge
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
ORDER BY 1,2


--TOTAL CASES VS TOTAL DEATHS IN KENYA IN PERCENTAGE

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As percenatge
FROM PortfolioProject..CovidDeaths$
WHERE location = 'kenya'
ORDER BY 1,2

--TOTAL CASES VS POPULATION 
-- WHAT PERCENTAGE OF POPULATION HAS COVID

SELECT location, date,  population, total_cases,(total_cases/population)*100 As percentageInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
ORDER BY 1,2

-- country with he highest infection rate compared to population

SELECT location, population, max(total_cases) As highestinfectioncount, max((total_cases/population))*100 As highestpercentageInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
GROUP BY population, location
ORDER BY 4 DESC


-- CONTINENT WITH THE HIGHEST RATE OF INFECTION

SELECT location, max(cast(total_cases as int)) As highestinfectioncount
FROM PortfolioProject..CovidDeaths$
WHERE continent is Null
GROUP BY  location
ORDER BY 2 DESC

-- COUNTRY WITH THE HIGHEST DEATHS 

SELECT location, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
GROUP BY location
ORDER BY 2 desc

-- BREAKDOWN BY CONTINENT (CONTINENT WITH HIGHEST TOTAL DEATHS)


SELECT location, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths$
WHERE continent is Null
GROUP BY location
ORDER BY 2 desc

-- OTHER VERSION OF CONTINENT WITH THE HIGHEST DEATH COUNTS

SELECT continent, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
GROUP BY continent
ORDER BY 2 desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as TotalNewCases, SUM( cast(new_deaths as int)) as TotalNewDeaths, 
SUM( cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
GROUP BY date
ORDER BY 1 asc

--PERCENTAGE OF DEATH IN THE WORLD

SELECT SUM(new_cases) as TotalNewCases, SUM( cast(new_deaths as int)) as TotalNewDeaths, 
SUM( cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
ORDER BY 1 asc




--TOTAL VACCINATION VS POPULATION

SELECT vac.continent, vac.location, vac.date, population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int ))
OVER ( PARTITION BY vac.location ORDER BY vac.location, vac.date) AS PeopleVaccinatedCount
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$  dea
ON vac.date = dea.date
AND vac.location = dea.location
WHERE vac.continent is not Null
ORDER BY 2

--TOTAL VACCINATION VS POPULATION IN PERCENTAGE (CTE TABLE)

WITH PopvsVac (continent, location, date, population, new_vaccinations,PeopleVaccinatedCount)
AS 
(
SELECT vac.continent, vac.location, vac.date, population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int ))
OVER ( PARTITION BY vac.location ORDER BY vac.location, vac.date) AS PeopleVaccinatedCount
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$  dea
ON vac.date = dea.date
AND vac.location = dea.location
WHERE vac.continent is not Null
)
SELECT *, (PeopleVaccinatedCount/population)*100 AS Popvacinatedpercentage
FROM PopvsVac

--TOTAL VACCINATION VS POPULATION IN PERCENTAGE (TEMP TABLE)

DROP TABLE IF exists #PercentageVacinatedPopulation
CREATE TABLE #PercentageVacinatedPopulation
(
continent nvarchar (255), 
location   nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
PeopleVaccinatedCount numeric
 )

INSERT INTO  #PercentageVacinatedPopulation
SELECT vac.continent, vac.location, vac.date, population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int ))
OVER ( PARTITION BY vac.location ORDER BY vac.location, vac.date) AS PeopleVaccinatedCount
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$  dea
ON vac.date = dea.date
AND vac.location = dea.location
WHERE vac.continent is not Null

SELECT *, (PeopleVaccinatedCount/population)*100 AS Popvacinatedpercentage
FROM #PercentageVacinatedPopulation
ORDER BY 2


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
--
CREATE VIEW VaccinationvsPopulation as
SELECT vac.continent, vac.location, vac.date, population, vac.new_vaccinations, SUM(CAST( vac.new_vaccinations AS int ))
OVER ( PARTITION BY vac.location ORDER BY vac.location, vac.date) AS PeopleVaccinatedCount
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$  dea
ON vac.date = dea.date
AND vac.location = dea.location
WHERE vac.continent is not Null

-- VIEW OF TOTAL CASES VS TOTAL DEATHS GLOBALLY
CREATE VIEW CasesvsDeathsGlobal AS 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As percenatge
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
--ORDER BY 1,2

-- VIEW OF TOATL CASES VS TOTAL DEATHS IN KENYA

CREATE VIEW CasesvsDeathsKenya as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As percenatge
FROM PortfolioProject..CovidDeaths$
WHERE location = 'kenya'
--ORDER BY 1,2

--INFECTION RATE IN PERCENTAGE

CREATE VIEW InfectionRate AS
SELECT location, date,  population, total_cases,(total_cases/population)*100 As percentageInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
--ORDER BY 1,2

-- TOTAL DEATHS (BY COUNTRY)

CREATE VIEW TotalDeaths AS
SELECT location, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
GROUP BY location
--ORDER BY 2 desc

--TOTAL DEATHS (BY CONTINENT)

CREATE VIEW TotalDeathsGlobal AS
SELECT continent, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not Null
GROUP BY continent
--ORDER BY 2 desc