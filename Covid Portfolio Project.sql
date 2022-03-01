Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at total cases vs total deaths in united states
-- Shows likelihood of dying after testing positive of COVID
--Can be whatever country you set with like or = 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population has gotten covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PositivePercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at countires with highest infection rate compared to population

Select Location, Population, max (total_cases) as HighestRecordedCases, (max (total_cases)/population)*100 as PercentofPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
group by location, population
order by PercentofPopulationInfected desc

--Showing countries with the highest death count per population

Select Location, max (cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
group by location, population
order by TotalDeathCount desc

--Now taking a look by continent
-- Showing contintents wiht the highest death count

Select continent, max (cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers by date

Select date, sum (new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

--global numbers all together

Select sum (new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
order by 1,2

--Joining Covid deaths with covid vaccinations

Select*
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


--Looking at total population vs vaccinations
-- adding up to find total vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as totalpeoplevaccinated--, (totalpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, date, population, new_vaccinations, totalpeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as totalpeoplevaccinated--, (totalpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (totalpeoplevaccinated/population)*100
From PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime, 
population numeric,
New_vaccinations numeric,
totalpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as totalpeoplevaccinated--, (totalpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, (totalpeoplevaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as totalpeoplevaccinated--, (totalpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated