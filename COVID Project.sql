--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likeliehood of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY InfectedPercentage desc

--Showing countries with the highest death count per population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--showing continents with the hgihest death count per continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER(Partition By dea.location ORDER BY dea.location, dea.date) AS SumOfNewVaccinations
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, SumOfNewVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER(Partition By dea.location ORDER BY dea.location, dea.date) AS SumOfNewVaccinations
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (SumOfNewVaccinations/Population)*100
FROM PopvsVac
