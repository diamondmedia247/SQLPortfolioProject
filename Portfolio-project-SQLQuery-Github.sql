
SELECT *
From PortfolioProject..CovidDeaths
Order by 3,4


--SELECT *
--From PortfolioProject..CovidVacinations
--Order by 3,4

-- Select Data that we are going to be using


SELECT location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contact covid in your country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where continent is not null
Where location like '%states%'
Order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationIfected
From PortfolioProject..CovidDeaths
--where continent is not null
Where location like '%states%'
Order by 1,2


-- Looking at country with highest infection rate compared to population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationIfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
--where continent is not null
Group by location, population
Order by PercentagePopulationIfected desc


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
Group by location
Order by TotalDeathCount desc


-- LET's BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- More accurate result this way

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is null
Group by location
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as tota_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%states%'
Group by date
Order by 1,2

-- also

SELECT SUM(new_cases) as tota_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%states%'
--Group by date
Order by 1,2


--Looking at the total population Vs vacination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- USE CTE

with PopvsVac  (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- Temp table

Create Table #PercentPopulationVaccinated
(
continent Nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Or


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent Nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3