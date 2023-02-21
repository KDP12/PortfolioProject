
--Covid Deaths Table
select * 
from portfolioproject..coviddeath
where continent is not null
order by 3,4


--Covid Vaccine Table
select * 
from portfolioproject..covidvaccine
order by 3,4

----------------------------------------------------------------------------------------------------------------------------------------------------------

select Location,date,total_cases, new_cases,total_deaths,population
from portfolioproject..coviddeath
order by 1,2


--Looking for total cases vs total deaths

--shows likelihood of deaths percentage wise

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from portfolioproject..coviddeath
where location like '%india%'
order by 1,2

----------------------------------------------------------------------------------------------------------------------------------------------------------

--Looking at total cases vs population

select Location,date,population,total_cases,(total_cases/population)*100 as Death_percentage
from portfolioproject..coviddeath
--where location like '%india%'
order by 1,2


----------------------------------------------------------------------------------------------------------------------------------------------------------


--Looking at countries with hihgest infection rate compared to population

select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as Percentpopulationinfected
from portfolioproject..coviddeath
--where location like '%india%'
group by population,location
order by Percentpopulationinfected desc


--Showing countries with highest death count per population

Select Location,max(cast(total_deaths as int)) as TotalDeathCount 
From portfolioproject..coviddeath
where continent is not null
--where location like '%india%'
group by Location
order by TotalDeathCount desc

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Lets break down by continent

--Showing the continents with highest death counts

Select continent,max(cast(total_deaths as int)) as TotalDeathCount 
From portfolioproject..coviddeath
where continent is not null
--where location like '%india%'
group by continent
order by TotalDeathCount desc


-----------------------------------------------------------------------------------------------------------------------------------------------------------

--Global Numbers

select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeath
--where location like '%india%'
where continent is not null
group by date
order by 1,2

--Total cases death percentage of the world

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeath
--where location like '%india%'
where continent is not null
order by 1,2

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at total population vs vaccination


select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100
from portfolioproject..coviddeath dea 
join portfolioproject..covidvaccine vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USING CTE

With PopvsVac(Continent,location,date,population,new_vaccinations,RollingPeoplevaccinated) 
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 
from portfolioproject..coviddeath dea 
Join portfolioproject..covidvaccine vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *,(RollingPeoplevaccinated/population)*100 
FROM popvsvac 


--USING TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 
from portfolioproject..coviddeath dea 
Join portfolioproject..covidvaccine vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *,(RollingPeoplevaccinated/population)*100 
FROM  #PercentPopulationVaccinated


-------------------------------------------------------------------------------------------------------------------------------------------------

--CREATING VIEW TO STORE DATA FOR VISUALIZATIONS



--Percent population Vaccinated

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 
from portfolioproject..coviddeath dea 
Join portfolioproject..covidvaccine vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



--Continent Death counts 

Create View ContinentDeathCounts as
Select continent,max(cast(total_deaths as int)) as TotalDeathCount 
From portfolioproject..CovidDeaths
where continent is not null
--where location like '%india%'
group by continent
--order by TotalDeathCount desc



--Total cases death percentage of the world

Create View WorldDeathPercentage as
select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
--order by 1,2


--Countries with hihgest infection rate compared to population

Create View CountryInfectionratePopulationwise as
select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as Percentpopulationinfected
from portfolioproject..CovidDeaths
--where location like '%india%'
group by population,location
--order by Percentpopulationinfected desc



--Likelihood of deaths percentage wise

Create View DeathLikelihoodPercentage as
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from portfolioproject..CovidDeaths
where location like '%india%'
--order by 1,2

-----------------------------------------------------------------------------------------------------------------------------------------------------------
