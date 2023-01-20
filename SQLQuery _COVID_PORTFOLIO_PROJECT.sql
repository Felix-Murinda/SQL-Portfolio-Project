Select *
From Portfolio_Project..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From Portfolio_Project..CovidVaccinations
--Order by 3,4

-- selecting the data i will use

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
Order by 1,2

--looking at total deaths vs total cases to see the likelihood of dying after contracting the disease
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Where location like '%state%'
Order by 1,2

--looking at total deaths vs population
Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From Portfolio_Project..CovidDeaths
Where location like '%state%'
Order by 1,2

--looking at countries with highest infection rate compared to their population
Select Location, population, MAX (total_cases) as highestinfectionrate, MAX(total_cases/population)*100 as infectedpopulationPercentage
From Portfolio_Project..CovidDeaths
--Where location like '%state%'
Group by Location, population
Order by infectedpopulationPercentage

--showing countries with highest death count per population
Select Location, MAX (cast(total_deaths as int)) as Totaldeathcount
From Portfolio_Project..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by Location 
Order by Totaldeathcount desc

--showing things as per continent
Select continent, MAX (cast(total_deaths as int)) as Totaldeathcount
From Portfolio_Project..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by continent 
Order by Totaldeathcount desc

--showing things as per continent
Select continent, MAX (cast(total_deaths as int)) as Totaldeathcount
From Portfolio_Project..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by continent 
Order by Totaldeathcount desc

--global numbers
Select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From Portfolio_Project..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by date
Order by 1,2

Select *
From Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date

Select death.continent,death.location,death.date,death.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as rollingpeoplevaccinated
From Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 2,3


--using CTE

With popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent,death.location,death.date,death.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From popvsvac


--TEMP TABLE
DROP Table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
Select death.continent,death.location,death.date,death.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
--Where death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #percentpopulationvaccinated



--creating view to store data for later visualization
Create View percentpopulationVaccinated as 
Select death.continent,death.location,death.date,death.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3

Select *
From percentpopulationVaccinated
