select * 
from PortfolioCOVIDProject..CovidDeaths
where continent is not null
order by 3,4;

Select Location,date, total_cases,new_cases,total_deaths,population
from PortfolioCOVIDProject..CovidDeaths
order  by 1,2;

--total cases vs total deaths
--likelihood of dying if you get covid in these specific country
Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percent
from PortfolioCOVIDProject..CovidDeaths
where location like '%states%'
order  by 1,2;

Select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percent
from PortfolioCOVIDProject..CovidDeaths
where location like '%nepal%'
order  by 1,2;


--looking at total  cases vs population
Select Location,date, total_cases,population, (total_cases/population)*100 as covid_percent
from PortfolioCOVIDProject..CovidDeaths
where location like '%nepal%'
order  by 1,2;

--looking at countries which has highest infection rate

select location, population, max(total_cases) as highestInfectionRate, 
max((total_cases/population)*100) as percentpopulationInfected
from PortfolioCOVIDProject..CovidDeaths
--where location like '%nepal%'
group by location, population
order by percentpopulationInfected desc;

--lets break things down by continent
select location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioCOVIDProject..CovidDeaths
where continent is null
--where location like '%nepal%'
group by location
order by totalDeathCount desc;


--Showing hghest death counts per popn
select location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioCOVIDProject..CovidDeaths
where continent is not null
--where location like '%nepal%'
group by location
order by totalDeathCount desc;


--Showing the continent with highest death count
select location, max(cast(total_deaths as int)) as totalDeathCount
from PortfolioCOVIDProject..CovidDeaths
where continent is not null
--where location like '%nepal%'
group by location
order by totalDeathCount desc;

--Breaking  Global numbers
Select date, sum(new_cases) as totalGlobalCase, sum(cast(new_deaths as int)) as totalGlobalDeaths, 
(sum(cast(new_deaths as int)) /sum(new_cases))*100 as death_percentage
from PortfolioCOVIDProject..CovidDeaths
where continent is not null
group by date
--where location like '%nepal%'
order  by 1,2;

--total death in global by covid
Select sum(new_cases) as totalGlobalCase, sum(cast(new_deaths as int)) as totalGlobalDeaths, 
(sum(cast(new_deaths as int)) /sum(new_cases))*100 as death_percentage
from PortfolioCOVIDProject..CovidDeaths
where continent is not null
--group by date
--where location like '%nepal%'
order  by 1,2;

--looking at total population vs total vaccination
--Using CTE(Common Table Expression)
With PopulationVsVaccination (continent, date, location, population, VaccinatedPopulation)
as
(
select dea.date, dea.continent, dea.location,dea.population, sum(convert(int,new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as VaccinatedPopulation
from PortfolioCOVIDProject..CovidVaccinations as vac
join PortfolioCOVIDProject..CovidDeaths as dea
on dea.location = vac.location
and
dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (VaccinatedPopulation/ population)*100 as VacPercent 
from PopulationVsVaccination;


--creating a temporary table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
date datetime,
location nvarchar(255),
continent nvarchar(255),
population numeric,
new_vaccinations numeric,
VaccinatedPopulation numeric
)

Insert into #PercentPopulationVaccinated
select dea.date, dea.continent, dea.location,dea.population,vac.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as VaccinatedPopulation
from PortfolioCOVIDProject..CovidVaccinations as vac
join PortfolioCOVIDProject..CovidDeaths as dea
on dea.location = vac.location
and
dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (VaccinatedPopulation/ population)*100 as VacPercent 
from #PercentPopulationVaccinated



--Creating View to stroe data for visualizations

Create View PercentPopulationVaccinated as
select dea.date, dea.continent, dea.location,dea.population,vac.new_vaccinations, sum(convert(int,new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as VaccinatedPopulation
from PortfolioCOVIDProject..CovidVaccinations as vac
join PortfolioCOVIDProject..CovidDeaths as dea
on dea.location = vac.location
and
dea.date= vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated;