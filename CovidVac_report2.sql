Select * from PortfolioProject2025.dbo.CovidDeaths
order by 3,4

--Select * from PortfolioProject2025.dbo.CovidVac
--order by 3,4


-- Select Data that we are going to be using 

Select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject2025.dbo.CovidDeaths
order by 1,2

--  Looking at the total_cases vs total_deaths

Select location,date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as PercentageOfDeath
from PortfolioProject2025.dbo.CovidDeaths
order by 1,2

--Likelihood of dying after contracting Covid in specific location/country

Select location,date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as PercentageOfDeath
from PortfolioProject2025.dbo.CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at total_cases vs population - shows what percentage got Covid


Select location, date, total_cases, population,(total_cases/population) * 100 as PercentageOfPopulationInfected
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states%'
order by 1,2

-- What country with highest infection rate compared to population

Select location, MAX( total_cases) as Highest_infection_count, population, MAX(total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states%'
--where population > 300000000
group by population,location
order by PercentPopulationInfected desc

-- show countries with highest dteah count per population, total_deaths are (NVARCHAR) so we need to cast as integer for count.

Select location, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states%'

group by location
order by Total_Death_count desc

-- to remove World, Europe  let's check location and clean it up - ' continent is not null '

Select * from PortfolioProject2025.dbo.CovidDeaths
where continent is not null
order by 3,4

Select location, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by Total_Death_count desc

-- Breaking down per continent -- Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by Total_Death_count desc

--Is it accurate? let's check another way

Select location, MAX(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states%'
where continent is  null
group by location
order by Total_Death_count desc


-- GLOBAL NUMBERS


Select date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as Total_new_deaths , SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as PercentageOfDeathGlobal
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states'
where continent is not null
group by date
order by 1,2


Select SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as Total_new_deaths , SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as PercentageOfDeathGlobal
from PortfolioProject2025.dbo.CovidDeaths
--where location like '%states'
where continent is not null
--group by date
order by 1,2


-- JOin Covid Vacc data to our tables

Select * 
from PortfolioProject2025.dbo.CovidDeaths dth
join PortfolioProject2025.dbo.CovidVac vac
	on dth.location = vac.location
	and dth.date = dth.date

-- Total Population Vaccinated

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
from PortfolioProject2025.dbo.CovidDeaths dth
join PortfolioProject2025.dbo.CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 1,2,3

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dth.location)
from PortfolioProject2025.dbo.CovidDeaths dth
join PortfolioProject2025.dbo.CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2,3

--Using a CTE

With PopVsVac (Continent, Location, Date, Population,New_vaccinations,  RollingCountVac)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dth.location
Order by dth.location,dth.date) as RollingCountVac
from PortfolioProject2025.dbo.CovidDeaths dth
join PortfolioProject2025.dbo.CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3
)

Select * , (RollingCountVac/population)* 100
from PopVsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingCountVac numeric
 )
Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dth.location
Order by dth.location,dth.date) as RollingCountVac
from PortfolioProject2025.dbo.CovidDeaths dth
join PortfolioProject2025.dbo.CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
--where dth.continent is not null
--order by 2,3


Select * , (RollingCountVac/population)* 100
from #PercentPopulationVaccinated

-- create a view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dth.location
Order by dth.location,dth.date) as RollingCountVac
from PortfolioProject2025.dbo.CovidDeaths dth
join PortfolioProject2025.dbo.CovidVac vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3


