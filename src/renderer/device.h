#pragma once

/*
LOOK INTO:

HRESULT IDirect3DDevice9::CreateDepthStencilSurface(
	UINT Width,
	UINT Height,
	D3DFORMAT Format,
	D3DMULTISAMPLE_TYPE MultiSample,
	DWORD MultisampleQuality,
	BOOL Discard,
	IDirect3DSurface9** ppSurface,
	HANDLE* pSharedHandle
);

HRESULT IDirect3DDevice9::CreateOffscreenPlainSurface(
	UINT Width,
	UINT Height,
	D3DFORMAT Format,
	DWORD Pool,
	IDirect3DSurface9** ppSurface,
	HANDLE* pSharedHandle
);

HRESULT IDirect3DDevice9::CreateRenderTarget(
	UINT Width,
	UINT Height,
	D3DFORMAT Format,
	D3DMULTISAMPLE_TYPE MultiSample,
	DWORD MultisampleQuality,
	BOOL Lockable,
	IDirect3DSurface9** ppSurface,
	HANDLE* pSharedHandle
);
*/

#include "core/comref.h"
namespace renderer
{
	class VertexBuffer;
	class IndexBuffer;
	class VertexDeclaration;

	class Texture;
	class VolumeTexture;
	class Surface;

	class Device : public ComRef<IDirect3DDevice9>
	{
	public:
		
		/* render targets */
		void Device::setRenderTarget(IDirect3DSurface9 *surface, unsigned index = 0);
		Surface getRenderTarget(unsigned index = 0);

		void setDepthStencilSurface(Surface &surface);
		Surface getDepthStencilSurface();

		D3DVIEWPORT9 getViewport() const
		{
			D3DVIEWPORT9 viewport;
			p->GetViewport(&viewport);
			return viewport;
		}
		
		void setViewport(const D3DVIEWPORT9 *viewport)
		{
			p->SetViewport(viewport);
		}

		/* vertex/index buffers */
		VertexBuffer createVertexBuffer(UINT length, DWORD usage, DWORD fvf, D3DPOOL pool = D3DPOOL_DEFAULT, HANDLE* handle = NULL);
		IndexBuffer createIndexBuffer(UINT length, DWORD usage, D3DFORMAT format, D3DPOOL pool = D3DPOOL_DEFAULT, HANDLE* handle = NULL);
		VertexDeclaration createVertexDeclaration(CONST D3DVERTEXELEMENT9* vertex_elements);

		/* textures / surfaces */
		Texture createTexture(UINT width, UINT height, UINT levels, DWORD usage, D3DFORMAT format, D3DPOOL pool = D3DPOOL_DEFAULT, HANDLE* handle = NULL);
		VolumeTexture createVolumeTexture(UINT width, UINT height, UINT detph, UINT levels, DWORD usage, D3DFORMAT format, D3DPOOL pool = D3DPOOL_DEFAULT, HANDLE* handle = NULL);

		Surface createDepthStencilSurface(
			UINT Width,
			UINT Height,
			D3DFORMAT Format = D3DFMT_D24S8,
			D3DMULTISAMPLE_TYPE MultiSample = D3DMULTISAMPLE_NONE,
			DWORD MultisampleQuality = 0,
			BOOL Discard = TRUE,
			HANDLE* pSharedHandle = NULL
		);

		Surface createRenderTarget(
			UINT Width,
			UINT Height,
			D3DFORMAT Format = D3DFMT_A8R8G8B8,
			D3DMULTISAMPLE_TYPE MultiSample = D3DMULTISAMPLE_NONE,
			DWORD MultisampleQuality = 0,
			BOOL Lockable = FALSE,
			HANDLE* pSharedHandle = NULL
		);

	};
};
