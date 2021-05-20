--making sure we have the table and correct data 
Select *
From PortfolioProject..CovidDeaths       --aternatively can use PortfolioProject.dbo.CovidDeaths
where continent is not null		--Excludes the data associated with the continents
order by 3,4				


select *
From PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4


--Selecting Data from CovidDeaths table
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null        
order by 1,2


--Total cases Vs Total deaths and covid death percentage in Nepal
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
where location like '%Nep%'
order by 1,2


--Total cases Vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Countries with highest infection rate with respect to population
Select location, population, MAX(total_cases) as HighestInfectionCount,
MAX(total_cases/population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentageOfPopulationInfected desc


--Breaking total cases countrywise
Select location, MAX(cast(total_cases as int)) as Total_Cases
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by Total_cases desc


--Breaking total deaths by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc
	
			  
--Countries with lowest death count per population
Select location, MIN(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount aesc			  


--Global numbers
Select date, SUM(new_cases) as TotalNewCasesDaily, SUM(cast(new_deaths as int)) as TotalNewDeathsDaily
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageDaily
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


--Global death percentage
Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Use Common Table Expression (CTE) --Total population Vs Vaccination
With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingVaccinationCount) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingVaccinationCount 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccinationCount/Population)*100 as PercentageVaccinated
From PopvsVac


--Temporary table
DROP Table if exists #PercentPopulationVaccinated     --Drops any existing table so that the values are accurate and updated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingVaccinationCount 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated



--Creating view to store data for Visualization
--creates a seperate table 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, dea.Date)
as RollingVaccinationCount 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select * 
From PercentPopulationVaccinated
