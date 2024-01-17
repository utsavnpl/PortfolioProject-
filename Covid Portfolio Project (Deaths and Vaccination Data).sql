select*
from PortfolioProject..CovidDeaths$
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select data that I will use for project
select location,date,total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths in Nepal
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Rate
from PortfolioProject..CovidDeaths$
where location like 'Nepal'
order by 1,2

--Looking at the total cases vs population
select location,date,total_cases,population, (total_cases/population)*100 as Infection_population
from PortfolioProject..CovidDeaths$
--where location like 'Nepal'
order by 1,2

-- Look at countries with Highest Infection Rate compared to pupulation 
select Location, population, max(total_cases)as HighestInfectionCount, Max((total_cases/population)*100) as Population_Infected_rate
from PortfolioProject..CovidDeaths$
--where location like 'Nepal'
Group by population, location
order by Population_Infected_rate desc

--Breaking things down by continent
select location as continent, max(cast(total_deaths as int))as HighestDeathCount--, Max((total_deaths/population)*100) as Population_Death_rate
from PortfolioProject..CovidDeaths$
--where location like 'Nepal'
where continent is null
Group by location
order by HighestDeathCount desc




---- Look at countries with Highest Death Count compared to pupulation 
select Location , population, max(cast(total_deaths as int))as HighestDeathCount--, Max((total_deaths/population)*100) as Population_Death_rate
from PortfolioProject..CovidDeaths$
--where location like 'Nepal'
where continent is not null
Group by population, location
order by HighestDeathCount desc

-- looking at continents with highest death count per population
select continent, max(cast(total_deaths as int))as TotalDeathCount--, Max((total_deaths/population)*100) as Population_Death_rate
from PortfolioProject..CovidDeaths$
--where location like 'Nepal'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Stats

select date,sum(new_cases) as cases, sum(cast(new_deaths as int))as deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as Death_Rate
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--total cases, total deaths with total death percentage
select sum(new_cases) as cases, sum(cast(new_deaths as int))as deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as Death_Rate
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at Vaccination table
Select *
From PortfolioProject..CovidVaccinations$

-- Joining Death and Vaccination Table 
Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 









