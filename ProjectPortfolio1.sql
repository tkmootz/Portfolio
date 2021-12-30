--Select data to use
SELECT location, date, total_cases, new_cases, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

--Total cases vs total deaths in country
--Shows likelihood of death from Covid infection by country and changing death rate over time
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

--Total cases vs population (i.e. infection rate)
SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_infection_ratio
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2;


--Looking at countries with highest infected population compared to total population
SELECT location, population, MAX(total_cases) AS total_cases, MAX((total_cases/population)) AS infected_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY infected_percentage DESC;

--Showing countries with highest rate of death from infection
SELECT location, population, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC;

--Breaking down deaths by continent
SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--Global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


--Looking at total population vs vaccinations



--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Sum)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vaccinations
--, (rolling_sum_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)

SELECT *, (Rolling_Sum/Population)*100 AS vaccination_percentage
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Sum numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vaccinations
--, (rolling_sum_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *, (Rolling_Sum/Population)*100
FROM #PercentPopulationVaccinated


