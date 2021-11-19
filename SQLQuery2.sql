/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..coviddeaths
where continent is not null
order by 3,4


--Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
order by 1,2

-- Looking at total cases vs total deaths. 
-- Shows likelyhood of dying if you contract covid in your country.

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..coviddeaths
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs population
-- Shows what percentage of population has gotten Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as Percentage_Covid
From PortfolioProject..coviddeaths
Where location like '%states%'
order by 1,2

-- looking at countires with highest infection rate compared to population

Select Location, population, Max(total_cases) as Highest_infection_count, (Max(total_cases)/population)*100 as Percentage_Covid
From PortfolioProject..coviddeaths
--Where location like '%states%'
Group by location, population
order by Percentage_Covid desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as total_deaths
From PortfolioProject..coviddeaths
--Where location like '%states%'
where continent is not null
Group by location
order by total_deaths desc

--Lets break things down by Continent

Select continent, MAX(cast(total_deaths as int)) as total_deaths
From PortfolioProject..coviddeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by total_deaths desc


--Showing the continents with highest death count

select continent, MAX(cast(Total_deaths as int)) as Total_deaths
From PortfolioProject..coviddeaths
Where continent is not null
Group by continent
order by Total_deaths desc

-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject..coviddeaths
Where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject..coviddeaths
Where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as peoplevaccinated, (
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvax vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With popvsvac (continent, location, date, population, new_vaccinations, peoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as peoplevaccinated

From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvax vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select*, (peoplevaccinated/population)*100
from popvsvac

-- Temp Table
-- If you need to make changes use "drop table if exists" above create table 
--example see below
Drop table if exists #percentpopulationvaccinated
create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric, 
new_vaccinations numeric,
peoplevaccinated numeric, 
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as peoplevaccinated

From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvax vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*, (peoplevaccinated/population)*100
from #percentpopulationvaccinated


-- Creating view to store data for later

create view percentpopulationvaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as peoplevaccinated
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvax vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

create view globalnumbers as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject..coviddeaths
Where continent is not null
group by date
--order by 1,2


create view deathcount as
select continent, MAX(cast(Total_deaths as int)) as Total_deaths
From PortfolioProject..coviddeaths
Where continent is not null
Group by continent
