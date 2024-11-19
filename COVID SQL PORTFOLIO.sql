Select *
From PortfolioProject..CovidDeaths
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccsv
--Order by 3,4

-- select the data we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2


--Looking at total cases vs total deaths

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT
ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT
Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2
-- had to change to float bc acting weird
--shows likelyhood of dying from covid this one is for US
Select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2



-- Looking at the total cases vs population
-- shows what population has gotten covid
Select location, date, total_cases, population, (total_cases/population)*100 as CasesbyPopulation
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--need to change date to date
ALTER TABLE CovidDeaths
ALTER COLUMN date DATE
ALTER TABLE CovidDeaths
ALTER COLUMN population FLOAT

Select location, date, total_cases, population, (total_cases/NULLIF(population,0))*100 as CasesbyPopulation
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

---countries with highest infection rate compared to population

Select location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/NULLIF(population,0)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population, total_cases
order by PercentPopulationInfected desc

--showing the countries with Highest Death Count Per Population

Select location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths

--WHERE location like '%states%'
GROUP BY location
order by TotalDeathCount desc
---need to remove continent
--by continenet

UPDATE CovidDeaths
SET continent = NULLIF(continent, ' ')

Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

--showing continents with highest death count
Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
ALTER TABLE CovidDeaths
ALTER COLUMN new_cases FLOAT
ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths FLOAT
Select date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(NULLIF(new_cases,' ')) * 100 as deathspercases 
From PortfolioProject..CovidDeaths
WHERE location like '%states%'
GROUP BY date
order by 1,2


--looking at total population vs vaccinations

ALTER TABLE CovidVaccsv
ALTER COLUMN new_vaccinations INT

SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations, SUM( dea.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccsv dea
JOIN PortfolioProject..CovidDeaths vac
ON  dea.location =vac.location
and dea.date = vac. date
WHERE dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)

as
(
SELECT dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations, SUM( dea.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccsv dea
JOIN PortfolioProject..CovidDeaths vac
ON  dea.location =vac.location
and dea.date = vac. date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/NULLIF(Population,' ')) * 100
FROM PopvsVac
