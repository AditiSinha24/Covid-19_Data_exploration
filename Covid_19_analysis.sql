/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4;

Select * 
from PortfolioProject.dbo.CovidVaccinations
order by 3,4;

--Select Data that we are going to be starting with

Select location,date ,total_cases ,new_cases , total_deaths , population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2;

--total deaths vs total cases
--Showing likelihood of dying if you get covid in your country
Select location,date ,total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%India'
order by 1,2;

--total cases vs population
-- Shows what percentage of population infected with Covid
Select location,date ,total_cases , population , (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%India'
order by 1,2;


--countries with Highest Infection Rate compared to population
Select location,population ,MAX(total_cases) as HighestInfectionCount ,  max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%India'
Group by location,population
order by PercentPopulationInfected desc;


--countries with highest death count per population
Select location , MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

--Breaking things down by continent
--Showing continents with highest deathcount per population
Select continent , MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

--GLOBAL NUMBERS
Select date ,sum(cast(new_deaths as int)),sum(new_cases) , sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2;

--Looking Total Population vs Total Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query


With PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
Select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/population)*100
from PopVsVac 


--Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 Select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
where dea.continent is not null


Select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated 


--Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as
	Select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
where dea.continent is not null
	

Select * 
from PercentPopulationVaccinated

