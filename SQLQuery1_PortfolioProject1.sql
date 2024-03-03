SELECT *
FROM PortfolioProject1..CovidDeaths
Order by 3,4

--SELECT *
--FROM PortfolioProject1..CovidVaccinations
--Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

-- Looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 as Percentpopulationinfected
FROM PortfolioProject1..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as Percentpopulationinfected
FROM PortfolioProject1..CovidDeaths
Where continent is not null
GROUP by location, population
Order by Percentpopulationinfected DESC

-- Showing countries with highest deathcount per population

SELECT Location, Population, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
Where continent is not null
GROUP by location, population
Order by TotalDeathCount DESC

--Let's Break things down by continent

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
Where continent is null
GROUP by location
Order by TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
Where continent is not null
GROUP by continent
Order by TotalDeathCount DESC

--Global numbers


SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--Where location like '%states%' 
Where continent is not null
Group by date
Order by 1,2

--total deaths percentage in the world

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--Where location like '%states%' 
Where continent is not null
Order by 1,2

--Inner join tables

Select * 
From PortfolioProject1..CovidDeaths as dea
Join PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date


--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Creating view of the deathpercentage in United States

Create View DeathPercentage as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
Where location like '%states%' and continent is not null
--Order by 1,2

-- Creating view of total cases vs population in United States

Create View Percentpopulationinfected as
SELECT location, date, total_cases, population, (total_cases/population)*100 as Percentpopulationinfected
FROM PortfolioProject1..CovidDeaths
Where location like '%states%' and continent is not null
--Order by 1,2


--Creating view of totaldeathcount by continent 

Create view TotalDeathCount as
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject1..CovidDeaths
Where continent is null
GROUP by location
--Order by TotalDeathCount DESC