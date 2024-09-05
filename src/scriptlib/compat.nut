g_engine	<-	0

function	RendererLoadWriterFont(renderer, base_path, path)
{	return ResourceFactoryLoadRasterFont(g_factory, base_path, path)	}

//-----------------------------------------------------------------------------
function	EngineGetRenderer(e)
{	return g_render	}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	EngineNewTexture(engine)
{	return ResourceFactoryNewTexture(g_factory)	}
function	EngineLoadTexture(engine, path)
{	return ResourceFactoryLoadTexture(g_factory, path)		}
function	EngineLoadGeometry(engine, path)
{	return ResourceFactoryLoadGeometry(g_factory, path)		}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	EngineLoadSound(engine, path)
{	return ResourceFactoryLoadSound(g_factory, path)		}
function	EngineLoadPicture(engine, path)
{	return ResourceFactoryLoadPicture(g_factory, path)		}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	EngineResetClock(engine)
{	ClockReset(ProjectGetClock(g_project))	}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	EngineGetToolMode(engine)
{
	return 0;
}
function	EnginePurgeResourceCache(engine)
{	return ResourceFactoryPurge(g_factory)	}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	ItemGetScene(item)
{	return g_scene	}
function	ItemActivate(item, v)
{	SceneItemActivate(g_scene, item, v)	}
function	ItemActivateHierarchy(item, v)
{	SceneItemActivateHierarchy(g_scene, item, v)	}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	EngineSetClockScale(engine, k)
{
}
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
function	WindowCentre(window)
{
}
//-----------------------------------------------------------------------------
