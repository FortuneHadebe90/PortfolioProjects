-- Data Exploration
select *
from PortfolioProject..coviddeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..covidvaccinations
where continent is not null
order by 3,4

-- Selecting the data to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2


--Total cases vs Total deaths in South Africa (chances of dying once infected)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..coviddeaths
where location like '%south africa%'
order by 1,2

--Total cases vs Total population in South Africa (chances of contracting covid)
select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from PortfolioProject..coviddeaths
where location like '%south africa%'
order by 1,2

-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentage_population_infected
from PortfolioProject..coviddeaths
--where location like '%south africa%'
where continent is not null
group by location, population
order by percentage_population_infected desc

-- Countries with highest death rate compared to population
-- total deaths is the wrong data type so we need to cast it as an integer
select location, population, max(cast(total_deaths as int)) as highest_death_count, max((total_deaths/population))*100 as highest_death_percentage
from PortfolioProject..coviddeaths
--where location like '%south africa%'
where continent is not null
group by location, population
order by highest_death_percentage desc

-- Highest death count by continent
select continent, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by total_death_count desc

--Global Numbers
--Total number of cases vs total number of dealth in the world daily
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject..coviddeaths
where continent is not null
group by date 
order by 1,2

--Now to include covid vaccinations
select *
from PortfolioProject..covidvaccinations
order by 3,4

--Joining covid vaccinations and covid death tables
select *
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date

--Total vaccination vs Population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
with PopvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccinations) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--order by 2,3
)
select *, (cumulative_vaccinations/population)*100 as cumulative_vaccination_percentage
from PopvsVac

--Cumulative vaccinations in South Africa
with PopvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccinations) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
where dea.location like '%south africa%'
--order by 2,3
)
select *, (cumulative_vaccinations/population)*100 as cumulative_vaccination_percentage
from PopvsVac

--temporary table 

drop table if exists #Percentage_Population_Vaccinated
create table #Percentage_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric, 
cumulative_vaccinations numeric,
)
insert into #Percentage_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (cumulative_vaccinations/population)*100 as cumulative_vaccination_percentage
from #Percentage_Population_Vaccinated

--Creating view for visualization in Tabluae

create view Percentage_Population_Vaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3