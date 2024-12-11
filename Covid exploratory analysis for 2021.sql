
SELECT * 
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject.. CovidVaccinations
--ORDER BY 3,4

-- Selecting the data i will be focusing on

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Assessing total cases vs total deaths
-- Shows amount of infected people who died
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercent
FROM PortfolioProject.. CovidDeaths
WHERE location like 'Nigeria'
ORDER BY 1,2

-- Assessing total cases vs population
-- shows population that got covid within that period

SELECT location, date, total_cases, population,(total_cases/population)*100 as populationpercent
FROM PortfolioProject.. CovidDeaths
WHERE location like 'Nigeria'
ORDER BY 1,2

-- looking at countries with highest infection rates
SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population)*100) as infectedpopulationpercent
FROM PortfolioProject.. CovidDeaths
-- WHERE location like 'Nigeria'
WHERE continent is not null
GROUP BY location, population
ORDER BY infectedpopulationpercent desc

-- showing countries with the highest covid death per population

SELECT location, MAX(total_deaths) as total_deathcount, MAX((total_deaths/population)*100) as deathedpopulationpercent
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY deathedpopulationpercent desc


SELECT location, MAX(total_deaths) as total_deathcount
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_deathcount desc

-- Analyzing based of continents
--HIGHEST
SELECT location, MAX(total_deaths) as highest_deathcount
FROM PortfolioProject.. CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY highest_deathcount desc
--TOTAL
SELECT location, SUM(new_deaths) as total_deathcount
FROM PortfolioProject.. CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_deathcount desc

-- USING CONTINENTS IN ORDER TO DRILL DOWN IN TABLEAU

--SELECT continent, MAX(total_deaths) as total_deathcount
--FROM PortfolioProject.. CovidDeaths
--WHERE continent is not null
--GROUP BY continent

-- TOTAL DEATHS PER CONTINENT
SELECT continent, SUM(new_deaths) as total_deathcount
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_deathcount desc

-- GLOBAL NUMBERS

-- STATISTIC AS AT THAT DAY
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as deathpercent
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- GLOBAL STATS PER DAY
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as deathpercent
FROM PortfolioProject.. CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- ASSESSING THE TOTAL POP and TOTAL VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.date) as Increasing_num_of_vaccinations
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3

	--  ASSESSING THE TOTAL POP vs TOTAL VACCINATION
	--USE CTE
	
WITH POPvsVAC (continent, location, date, population, new_vaccinations, Increasing_num_of_vaccinations)
as
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.date) as Increasing_num_of_vaccinations
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (Increasing_num_of_vaccinations/population)*100
FROM POPvsVAC


--THE COUNTRIES WITH THE MOST VAXED POPULATION



--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Increasing_num_of_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.date) as Increasing_num_of_vaccinations
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, (Increasing_num_of_vaccinations/population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.date) as Increasing_num_of_vaccinations
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3