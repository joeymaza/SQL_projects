
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

--create view

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