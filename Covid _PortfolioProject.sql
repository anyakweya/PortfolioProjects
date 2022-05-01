Use CovidDB
Go


select*
From CovidDeaths
Order by 3,4

--select*
--From CovidVaccination			
--Order by 3,4

Select location,population, date,total_cases,new_cases,total_deaths
From CovidDeaths
Where continent is not Null
order by 1,3 

--Total cases vs Total deaths
---Shows likelyhood of dying if you contract Covid in your country
Select  location, date, total_cases,total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
where location like '%States%'
order by 1,2 

--Total cases vs Population
--shows what percentage of population has covid
Select  location, date, population, total_cases, 
(total_cases/population)*100 AS PercentofPopulationInfected
From CovidDeaths
--where location like '%States%'
Where continent is not Null
--Group by
order by 1,2 

--Countries with highest infection rate compared to Population
Select  location,  population, MAX(total_cases)as HighestInfectionCount, 
MAX(total_cases/population)*100 AS PercentofPopulationInfected
From CovidDeaths
--where location like '%States%'
Where continent is not Null
Group by location,population
order by PercentofPopulationInfected desc

--Countries with highest Death Count per population
Select  location,   MAX(CAST(total_deaths as int))as TotalDeathCount
From CovidDeaths
--where location like '%States%'
Where continent is not Null
Group by location
order by TotalDeathCount desc

--BREAKDOWN BY CONTINENT
Select  location,   MAX(CAST(total_deaths as int))as TotalDeathCount
From CovidDeaths
--where location like '%States%'
Where continent is Null
Group by location
order by TotalDeathCount desc 

--Continent with the highest death count per population
Select  continent,   MAX(CAST(total_deaths as int))as TotalDeathCount
From CovidDeaths
--where location like '%States%'
Where continent is  not Null
Group by continent
order by TotalDeathCount desc 

--GLOBAL NUMBERS

Select  date, Sum(new_cases) as TotalNew_Cases,SUM(Cast(new_deaths AS INT)) as TotalNew_Deaths,     --total_cases,total_deaths, 
SUM(Cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
From CovidDeaths
--where location like '%States%'
where continent is not null
Group by date
order by 1,2 

 --Globally
Select   Sum(new_cases) as TotalNew_Cases,SUM(Cast(new_deaths AS INT)) as TotalNew_Deaths,     --total_cases,total_deaths, 
SUM(Cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
From CovidDeaths
--where location like '%States%'
where continent is not null
--Group by date
order by 1,2 

--Total Population vs Vaccinations

Select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations,
Sum(CONVERT(bigint,CV.new_vaccinations)) OVER(Partition BY CD.Location order by CD.Location,CD.Date) as RollingPeopleVaccinated
From CovidDeaths CD
join CovidVaccination CV on CD.date=CV.date
and CD.location=CV.location
Where CD.continent is not Null
Order By 2,3

--USE CTE

With PopsVsVacc(Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated) 
AS
(
Select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations,
Sum(CONVERT(bigint,CV.new_vaccinations)) OVER(Partition BY CD.Location order by CD.Location,CD.Date) as RollingPeopleVaccinated
From CovidDeaths CD
join CovidVaccination CV on CD.date=CV.date
and CD.location=CV.location
Where CD.continent is not Null
--Order By 2,3
)
Select*,(RollingPeopleVaccinated/Population)*100
From PopsVsVacc

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date DateTime,
Population numeric,
New_Vaccination Numeric,
RollingPeopleVaccinated Numeric,)

INSERT INTO #PercentPopulationVaccinated
Select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations,
Sum(CONVERT(bigint,CV.new_vaccinations)) OVER(Partition BY CD.Location order by CD.Location,CD.Date) as RollingPeopleVaccinated
From CovidDeaths CD
join CovidVaccination CV on CD.date=CV.date
and CD.location=CV.location
Where CD.continent is not Null
--Order By 2,3

Select*,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATE VIEW FOR VISUALIZATION 
Create view PercentPopulationVaccinated as
Select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations,
Sum(CONVERT(bigint,CV.new_vaccinations)) OVER(Partition BY CD.Location order by CD.Location,CD.Date) as RollingPeopleVaccinated
From CovidDeaths CD
join CovidVaccination CV on CD.date=CV.date
and CD.location=CV.location
Where CD.continent is not Null
--Order By 2,3

Create View DeathPercentage as
Select   Sum(new_cases) as TotalNew_Cases,SUM(Cast(new_deaths AS INT)) as TotalNew_Deaths,     --total_cases,total_deaths, 
SUM(Cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
From CovidDeaths
--where location like '%States%'
where continent is not null
--Group by date
--order by 1,2 

Create view HighestDeathCount as
Select  continent,   MAX(CAST(total_deaths as int))as TotalDeathCount
From CovidDeaths
--where location like '%States%'
Where continent is  not Null
Group by continent
--order by TotalDeathCount desc 


