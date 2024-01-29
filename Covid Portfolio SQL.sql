--SELECT * 
--FROM PortfolioProject..CovidVaccinations;

--SELECT *
--FROM PortfolioProject..CovidDeaths

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if youy contract covid in your country
SELECT Location, date, total_cases, total_deaths, (Total_Deaths / total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (Total_cases / population) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate vs Population

SELECT Location, population, Max(total_cases) as HighestInfectionCount, MAX((Total_cases / population)) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP by location, population
order by 4 DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, Max(cast(total_deaths as Int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by location
order by 2 DESC

-- Let's Break Things Down by Continent

SELECT continent, Max(cast(total_deaths as Int)) as total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by continent
order by 2 DESC

-- Showing continents with the highest death count

SELECT continent, population, Max(cast(total_deaths as Int)/population * 100) as total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by continent
order by 2 DESC

-- GLOBAL numbers 

SELECT date, SUM(new_cases) as total_cases, sum(cast(new_deaths as float)) as total_deaths, Sum(cast(new_deaths as float))/Sum(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1, 2

--!!!!!! Looking at Total Population vs Vaccinations -- NIEHWATAJET new_vaccination w tablice, nado dobawit i peredelat !!!!!!

SELECT dea.continent, dea.location, dea.date, dea.population, , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dealocation, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)

as (
SELECT dea.continent, dea.location, dea.date, dea.population, , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dealocation, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac

-- TEMP TABLE 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar(255),
dATE DATETIME, 
POPULATION NUMERIC, 
NEW_VACCINATIONS numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dealocation, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

-- Creating view to store date for later visualizations

Create View PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dealocation, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT * 
FROM PercentPopulationVaccinated