-- MYSQL COVID OVERVIEW SWITZERLAND AND GLOBAL
-- The dataset is located at https://ourworldindata.org/covid-deaths (date collection: 25-11-2022)

-- General overview about Swiss Covid cases and deaths
SELECT 
location as Country, continent as Continent, date as Date , total_cases as TotalCases, new_cases as NewCases, total_deaths as TotalDeaths, population  as Population
FROM coviddeath
WHERE continent != "null" AND location like "Switzerland"
ORDER BY location, date;

-- Looking at total covid cases vs. total deaths in relation to covid in Switzerland (DeathPercentage) per date

SELECT 
location as Country, date as Date, total_cases as TotalCases, total_deaths as TotalDeaths, TRUNCATE((total_deaths/total_cases)*100, 3) as DeathPercentage
FROM coviddeath
WHERE continent != "null" AND location like "Switzerland"
ORDER BY location, date DESC;

-- This table hows what percentage of population got covid in Switzerland per date

SELECT 
location as Country, date as Date, total_cases as TotalCases, population as Population, TRUNCATE((total_cases/population)*100, 3) as CovidPercentage
FROM coviddeath
WHERE continent != "null" AND location like "Switzerland"
ORDER BY location, date DESC;

-- This table shows which percentage of the global country population got infected (PercentPopulationInfected) 
-- This table shows also the total infection count by country

SELECT 
location as Country, population as Population, MAX(total_cases) as HighestInfectionCount, TRUNCATE(MAX(total_cases/population)*100, 3) as PercentPopulationInfected
FROM coviddeath
WHERE continent != "null"
GROUP BY location, population
ORDER BY 4 DESC;

-- This table shows which percentage of the global country population died in combination with covid (PercentPopulationDied) 
-- This table shows also the total death count by country

SELECT 
location as Country, population as Population, MAX(total_deaths) as HighestDeathCount, TRUNCATE(MAX(total_deaths/population)*100, 3) as PercentPopulationDied
FROM coviddeath
WHERE continent != "null"
GROUP BY location, population
ORDER BY 4 DESC;

-- This table shows the deaths per country in combination with covid, sorted by the highest death counts.

SELECT 
location as Country, MAX(total_deaths) as TotalDeathCount
FROM coviddeath
WHERE continent != "null"
GROUP BY location, population
ORDER BY 2 DESC;

-- This table shows the deaths per continent in combination with covid, sorted by the highest death counts.

SELECT 
continent as Continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeath
WHERE continent != "null"
GROUP BY continent
ORDER BY 2 DESC;

-- This caulculation shows the total covid cases, deaths and the death percentage global

SELECT 
SUM(new_cases) as CovidCases, SUM(new_deaths) as CovidDeaths, TRUNCATE(SUM(new_deaths)/SUM(new_cases)*100, 3) as DeathPercentage
FROM coviddeath
WHERE continent != "null";
-- GROUP BY date;

-- In this table, I have joined the table with covid vaccinations, to show the vaccinations per country.
-- You can see her the new vaccinations and the rolling vaccination count by date and by country.

SELECT 
dea.continent as Continent, dea.location as Country, dea.date as Date, dea.population as Population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeath as dea
JOIN covidvaccination as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent != "null"
ORDER BY 2,3;

-- In this section I have used a CTE for the further calulation with PopvsVac

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
dea.continent as Continent, dea.location as Country , dea.date as Date, dea.population as Population, 
vac.new_vaccinations as NewVaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeath as dea
JOIN covidvaccination as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent != "null"
ORDER BY 2
)
SELECT *, ((RollingPeopleVaccinated/population)*100) as RollingPeopleVac
FROM PopvsVac;

-- Here I have created a View for further visualization tasks

Create View PopvsVac as
SELECT 
dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeath as dea
JOIN covidvaccination as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent != "null";

-- DATA INTERPRETATION
-- The datasets seems to be in an accurate range. I have rechecked the numbers with differen online sources.
-- In the calculations above, we have one challenge: the calculations do not take into account that a person may be vaccinated/infected more than once.  
-- This fact distorts the results of the vaccination rate and the covid rate. 
