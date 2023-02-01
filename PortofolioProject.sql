--select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

--select *
--from PortofolioProject..CovidDeaths
--order by 3,4

--select data that we are going using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likehood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
Where location like '%indonesia%'
order by 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
--Where location like '%indonesia%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighesInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
--Where location like '%indonesia%'
group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--where location like %indonesia%
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
--where location like %indonesia%
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
-- Where location like '%indonesia%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
	   RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte
with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
	   RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
	   RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as
	   RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

use PortofolioProject
set ansi_nulls on
set quoted_identifier on

Select *
From PercentPopulationVaccinated
