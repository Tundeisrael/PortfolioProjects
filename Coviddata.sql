Covid-19 Dataset

-- View the entire covid deaths data and order it by location and date.

select *
from coviddeaths
where continent is not null
order by 3,4

-- Select the data i want to use from the covid deaths data

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2

-- Compare Total Deaths vs Total Cases
-- This shows chances of dying if you contact Covid in your country.

select location, date, total_cases, total_deaths,(total_deaths/ total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%Australia%'
order by 1,2

-- Compare Total Cases vs Population
-- This shows what percentage of population got covid

select location, date,  population, total_cases,(total_cases/ population)*100 as PercentPopulationInfected
from coviddeaths
--where location like '%Australia%'
order by 1,2

--looking at countries with highest infection rate compared to the population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/ population))*100 as PercentPopulationInfected
from coviddeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Countries showing the highest death count per population

select location, population, max(cast(Total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location, population
order by TotalDeathCount

--Showing data by continent; Continent with the highest death count

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers (Cases,Deaths and Death Percentage)

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
order by 1,2

-- Join both tables
-- Show total population vs total vaccination.

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from covidvaccination vac
join coviddeaths dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
WITH PopvsVac(continent,location,date,population,new_vaccinations,CummulativePpleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativePpleVaccinated
from covidvaccination vac
join coviddeaths dea
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select *, (CummulativePpleVaccinated/population)*100 as PercentRatio
from PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,	
CummulativePpleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativePpleVaccinated
from covidvaccination vac
join coviddeaths dea
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null

select *, (CummulativePpleVaccinated/population)*100 as PercentRatio
from #PercentPopulationVaccinated




