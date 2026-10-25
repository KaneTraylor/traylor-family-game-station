//--------------------------------------------------------------------------------------
//  Filename:       CoverflowShader.fx
//  Author:         Phoenix (Default skin) - Polar Glass additions
//  Description:    HLSL Pixel and Vertex Shader for Aurora's coverflow rendering
//
//  Polar Glass: when the active layout's camera position z is -7.75 ("Polar Glass" layout),
//  covers are placed directly in screen pixels (world x/y * 100 = screen px, y up), drawn
//  flat with rounded corners, and the centre cover gets the accent focus ring.  The mirror
//  pass draws the centre cover a second time at the Home hero position.
//  Every other layout uses the Default skin's code path unchanged.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Global Matrices
//--------------------------------------------------------------------------------------
float4x4 g_mWorldViewProjection;						// World View Projection Matrix
float4x4 g_mWorldInverseTranspose;						// World Inverse Transpose Matrix
float4x4 g_mWorld;										// World Matrix
float4x4 g_mView;										// View Matrix
float4x4 g_mProjection;									// Projection Matrix
float4x4 g_mViewProjection;								// View Projection Matrix

//--------------------------------------------------------------------------------------
// Global Camera Properties
//--------------------------------------------------------------------------------------
float3 g_fCameraPositionW;								// Camera position in world space
float3 g_fCameraDirectionW;								// Camera direction in world space

//--------------------------------------------------------------------------------------
// Global Light Properties
//--------------------------------------------------------------------------------------
float3 g_fLightPositionW;								// Light position in world space
float3 g_fLightDirectionW;								// Light direction in world space
float3 g_fLightAttenuation;								// Light attenuation factors
float3 g_fLightSpotPower;								// Light spot power

//--------------------------------------------------------------------------------------
// Global Material Properties
//--------------------------------------------------------------------------------------
float3 g_fAmbientMaterial	= { 0.40f, 0.40f, 0.40f };	// Ambient Material (Intensity)
float3 g_fAmbientColor		= { 1.00f, 1.00f, 1.00f };	// Ambient Light Color
float3 g_fDiffuseMaterial	= { 0.75f, 0.75f, 0.75f };	// Diffuse Material (Intensity)
float3 g_fDiffuseColor		= { 1.00f, 1.00f, 1.00f };	// Diffuse Light Color
float3 g_fSpecularMaterial	= { 0.00f, 0.00f, 0.00f };	// Specular Material (Intensity)
float3 g_fSpecularColor		= { 1.00f, 1.00f, 1.00f };	// Specular Light Color
float  g_fSpecularPower		= 0.0f;						// Specular Power Factor

//--------------------------------------------------------------------------------------
// Global Variables
//--------------------------------------------------------------------------------------
float g_fApplicationTime;								// Total application run-time (seconds)
float g_fElapsedTime;									// Elapsed application run-time (seconds)
int	  g_iCurrentSubsetId;								// Mesh subset of current case
int	  g_iCurrentObjectId;								// Cover Index of current case
int	  g_iCenterObjectId;								// Cover Index of center case (for comparison to current)
int   g_iCoverSubsetId = 1;								// Cover subset index (for comparison to current)
int   g_iCaseSubsetId = 0;								// Case subset index (for comparison to current)
bool  g_bContentEnabled		= true;						// Flag to determine if current case is 'enabled'
bool  g_bContentHidden		= false;					// Flag to determine if current case is 'hidden'
bool  g_bContentFavorite	= false;					// Flag to determine if the current case is 'favorite'

//--------------------------------------------------------------------------------------
// Polar Glass constants
//--------------------------------------------------------------------------------------
static const float  PG_MAGIC_Z    = -7.75f;				// layout camera z that switches the Polar Glass path on
static const float2 PG_RECT_MIN   = float2( -0.3501f, -0.4884f );	// front cover face, mesh space
static const float2 PG_RECT_MAX   = float2(  0.3413f,  0.4882f );
static const float  PG_EXPAND     = 1.10f;				// grow the quad so the focus ring fits outside the art
static const float2 PG_RT_ORIGIN  = float2( -320.0f, -205.0f );	// texCoverflow position in Aurora_Main
static const float2 PG_RT_SIZE    = float2( 1920.0f, 1080.0f );	// texCoverflow size in Aurora_Main
static const float2 PG_HERO_C     = float2( 192.0f, 276.0f );	// Home hero cover centre (190 x 266)
static const float2 PG_HERO_PPU   = float2( 274.805f, 272.373f );	// hero px per mesh unit
static const float3 PG_ACCENT     = float3( 0.960784f, 0.960784f, 0.968627f );	// focus ring: white glass	// #3DF5A6
static const float3 PG_GROUND     = float3( 0.039216f, 0.043137f, 0.078431f );	// #0A0B14	// #070A0F

//--------------------------------------------------------------------------------------
// Global Texture Samplers
//--------------------------------------------------------------------------------------
texture inputTexture0;
sampler TextureSampler = sampler_state
{
	Texture = (inputTexture0);
	MinFilter = Anisotropic;
	MagFilter = Anisotropic;
	MaxAnisotropy = 16;
};

//--------------------------------------------------------------------------------------
// Global Vertex/Pixel Shader Structs
//--------------------------------------------------------------------------------------
struct VERTEX_IN
{
	float3 Position		: POSITION0;
	float3 Normal		: NORMAL0;
	float2 TexCoords	: TEXCOORD0;
};

struct VERTEX_TO_PIXEL
{
	float4 Position		: POSITION;
	float4 Lights		: COLOR0;
	float2 TexCoords	: TEXCOORD0;
	float3 PositionL	: TEXCOORD1;
	float3 PositionW	: TEXCOORD2;
	float4 PolarGlass	: TEXCOORD3;					// x: px per unit, y: ring, z: visibility, w: active
};

//--------------------------------------------------------------------------------------
// Function - Make Greyscale
//--------------------------------------------------------------------------------------
inline float4 MakeGreyscale( float3 inputColor, float inputAlpha )
{
	float3 greyscale = dot( inputColor.rgb, float3( 0.3f, 0.59f, 0.11f ) );
	return float4( greyscale.rgb * 0.25f, inputAlpha * 0.98f );
}

//--------------------------------------------------------------------------------------
// Polar Glass helpers
//--------------------------------------------------------------------------------------
inline float PG_ObjZ()
{
	return mul( float4( 0.0f, 0.0f, 0.0f, 1.0f ), g_mWorld ).z;
}

inline float PG_Active()
{
	return ( abs( abs( PG_ObjZ() ) - 7.8f ) < 0.1f ) ? 1.0f : 0.0f;
}

inline float PG_IsCenter()
{
	return ( abs( (float)g_iCurrentObjectId - (float)g_iCenterObjectId ) < 0.5f ) ? 1.0f : 0.0f;
}

inline float PG_HomeMode()
{
	// cover world z is 7.75 in the Home modes and 7.85 in the Game Details modes
	return ( abs( PG_ObjZ() ) < 7.8f ) ? 1.0f : 0.0f;
}

inline float4 PG_ScreenToClip( float2 px )
{
	float2 n = ( px - PG_RT_ORIGIN ) / PG_RT_SIZE;
	return float4( n.x * 2.0f - 1.0f, 1.0f - n.y * 2.0f, 0.5f, 1.0f );
}

// Screen-pixel placement of a cover from its world matrix (world units * 100 = px, y up)
VERTEX_TO_PIXEL PG_Place( VERTEX_IN Input, float isMirror )
{
	VERTEX_TO_PIXEL Output = (VERTEX_TO_PIXEL)0;
	float2 rectC = ( PG_RECT_MIN + PG_RECT_MAX ) * 0.5f;
	float2 local = rectC + ( Input.Position.xy - rectC ) * PG_EXPAND;

	float3 objW = mul( float4( 0.0f, 0.0f, 0.0f, 1.0f ), g_mWorld ).xyz;
	float2 scl  = float2( length( g_mWorld[0].xyz ), length( g_mWorld[1].xyz ) );
	float  center = PG_IsCenter();
	float  home = PG_HomeMode();

	float2 ppu = scl * 100.0f;
	float2 px  = float2( objW.x * 100.0f, -objW.y * 100.0f ) + float2( 1.0f, -1.0f ) * ( local - rectC ) * ppu;

	// visible window for the cover row: slots centred 120..1152; fade one slot beyond either end
	float cx  = objW.x * 100.0f;
	float vis = saturate( ( cx + 9.0f ) / 129.0f ) * saturate( ( 1281.0f - cx ) / 129.0f );

	if( isMirror > 0.5f )
	{
		// mirror pass: only the centre cover, only on Home, drawn at the hero position
		ppu = PG_HERO_PPU;
		px  = PG_HERO_C + float2( 1.0f, -1.0f ) * ( local - rectC ) * ppu;
		vis = center * home;
	}

	Output.Position = PG_ScreenToClip( px );
	if( vis < 0.001f )
	{
		Output.Position = float4( 0.0f, 0.0f, -2.0f, 1.0f );
	}
	Output.Lights = float4( 1.0f, 1.0f, 1.0f, 1.0f );
	Output.TexCoords = Input.TexCoords;
	Output.PositionL = float3( local, Input.Position.z );
	Output.PositionW = objW;
	Output.PolarGlass = float4( ppu.x, center * home, vis, ( center > 0.5f || home < 0.5f ) ? 1.0f : 0.86f );
	return Output;
}

float4 PG_Shade( VERTEX_TO_PIXEL Input )
{
	clip( ( g_iCurrentSubsetId == g_iCaseSubsetId ) ? -1.0f : 1.0f );
	float  ppu   = Input.PolarGlass.x;
	float2 rectC = ( PG_RECT_MIN + PG_RECT_MAX ) * 0.5f;
	float2 halfSz = ( PG_RECT_MAX - PG_RECT_MIN ) * 0.5f;
	float2 dpx   = ( abs( Input.PositionL.xy - rectC ) - halfSz ) * ppu;	// >0 outside, in px
	float2 qd    = dpx + 14.0f;										// 14px continuous-corner covers
	float  d     = length( max( qd, 0.0f ) ) - 14.0f;					// exact outside, <= 0 inside
	float  coverA = saturate( 0.5f - d );
	float  ringA  = Input.PolarGlass.y * saturate( 2.0f - abs( d - 4.5f ) ) * ( 1.0f - coverA );
	float2 t  = saturate( ( Input.PositionL.xy - PG_RECT_MIN ) / ( PG_RECT_MAX - PG_RECT_MIN ) );
	float3 art = tex2D( TextureSampler, float2( 0.528f + t.x * 0.471f, 0.998f - t.y * 0.994f ) ).rgb;
	art = lerp( PG_GROUND, art, Input.PolarGlass.w );
	float a = ( coverA + ringA ) * Input.PolarGlass.z;
	clip( a - 0.02f );
	return float4( art * coverA + PG_ACCENT * ringA, a );
}

//--------------------------------------------------------------------------------------
// Coverflow - Normal/Mirror - Vertex Shader (Default)
//--------------------------------------------------------------------------------------
VERTEX_TO_PIXEL CoverflowDefault_VS( VERTEX_IN Input )
{
	// Initialize the output struct
	VERTEX_TO_PIXEL Output = (VERTEX_TO_PIXEL)0;

	// Transform vertex into screen space using WVP matrix
	Output.Position = mul( float4( Input.Position, 1.0f ), g_mWorldViewProjection );

	// Calculate normal unit vector for vertex using World Inverse Transpose matrix
	float3 normalW = mul( float4( Input.Normal, 0.0f ), g_mWorldInverseTranspose).xyz;
	normalW = normalize(normalW);

	// Transform vertex into world space using world matrix
	float3 posW = mul( float4( Input.Position, 1.0f ), g_mWorld ).xyz;

	// Calculate the world space light vector using light position and vertex position
	float3 lightVecW = normalize(g_fLightPositionW - posW);

	// Calculate the ambient light contribution
	float3 ambient = (g_fAmbientMaterial * g_fAmbientColor).rgb;

	// Calculate the diffuse light contribution
	float3 s = saturate(dot(lightVecW, normalW));
	float3 diffuse = s * (g_fDiffuseMaterial * g_fDiffuseColor).rgb;

	// Calculate the specular light contribution
	float3 toEyeW = normalize( g_fCameraPositionW - posW );
	float3 reflectW = reflect( -lightVecW, normalW );
	float t = pow(max(dot(reflectW, toEyeW), 0.0f), g_fSpecularPower );
	float3 spec = t * (g_fSpecularMaterial * g_fSpecularColor ).rgb;

	// Calculate the attenuation factor
	float d = distance( g_fLightPositionW, posW );
	float A = g_fLightAttenuation.x + g_fLightAttenuation.y*d + g_fLightAttenuation.z*d*d;

	// Calculate the spot light factor
	float spot = pow(max(dot(-lightVecW, g_fLightDirectionW), 0.0f ), g_fLightSpotPower );

	// Calculate the final light contribution
	float3 color = spot * (ambient + ((diffuse + spec) / A ));

	// Complete the Output structure for the vertex shader
	Output.Lights = float4( color, 1.0f );
	Output.PositionL = Input.Position;
	Output.PositionW = posW;
	Output.TexCoords = Input.TexCoords;
	Output.PolarGlass = float4( 0.0f, 0.0f, 1.0f, 1.0f );

	// Return results for pixel shader
	return Output;
}

VERTEX_TO_PIXEL CoverflowNormal_VS( VERTEX_IN Input )
{
	if( PG_Active() > 0.5f )
	{
		return PG_Place( Input, 0.0f );
	}
	return CoverflowDefault_VS( Input );
}

VERTEX_TO_PIXEL CoverflowMirror_VS( VERTEX_IN Input )
{
	if( PG_Active() > 0.5f )
	{
		return PG_Place( Input, 1.0f );
	}
	return CoverflowDefault_VS( Input );
}

//--------------------------------------------------------------------------------------
// Coverflow - Normal - Pixel Shader
//--------------------------------------------------------------------------------------
float4 CoverflowNormal_PS( VERTEX_TO_PIXEL Input ) : COLOR
{
	if( Input.PolarGlass.x > 0.5f )
	{
		return PG_Shade( Input );
	}

	// Retrieve color sample from texture
	float4 baseColor = tex2D( TextureSampler, Input.TexCoords );

	// Calculate our final color
	float colorFactor = 1.3f;
	float3 finalColor = ( baseColor.rgb * Input.Lights.rgb * colorFactor );
	float finalAlpha = 1.0f;

	// Adjust color for disabled content
	if( g_bContentEnabled == false )
	{
		finalColor = MakeGreyscale( finalColor, finalAlpha );
	}

	// Adjust color for hidden content
	if( g_bContentHidden == true )
	{
		finalAlpha = finalAlpha * 0.65f;
	}

	if( g_iCurrentSubsetId == g_iCaseSubsetId && g_bContentFavorite == true )
	{
		finalColor = finalColor + 0.125f * sin( g_fApplicationTime * 3.5f );
	}

	// Return final results
	return float4( finalColor.rgb, finalAlpha );
}

//--------------------------------------------------------------------------------------
// Coverflow - Mirror - Pixel Shader
//--------------------------------------------------------------------------------------
float4 CoverflowMirror_PS( VERTEX_TO_PIXEL Input ) : COLOR
{
	if( Input.PolarGlass.x > 0.5f )
	{
		return PG_Shade( Input );
	}

	// Retrieve color sample from texture
	float4 baseColor = tex2D( TextureSampler, Input.TexCoords );

	// Create fade on the mirror
	float height = Input.PositionW.y + 0.42f;
	float alphaFactor = saturate(0.50f - abs(height)) ;

	// Calculate our final color
	float colorFactor = 0.975f;
	float3 finalColor = ( baseColor.rgb * Input.Lights.rgb * colorFactor );
	float finalAlpha = alphaFactor;

	// Adjust color for disabled content
	if( g_bContentEnabled == false )
	{
		finalColor = MakeGreyscale( finalColor, finalAlpha );
	}

	// Adjust color for hidden content
	if( g_bContentHidden == true )
	{
		finalAlpha = finalAlpha * 0.65f;
	}

	// Return final results
	return float4( finalColor.rgb, finalAlpha );
}

//--------------------------------------------------------------------------------------
// Technique - Normal - Render Coverflow normally
//--------------------------------------------------------------------------------------
technique RenderCover
{
    pass Pass0
    {
        VertexShader = compile vs_2_0 CoverflowNormal_VS();
        PixelShader  = compile ps_2_0 CoverflowNormal_PS();
    }
}

//--------------------------------------------------------------------------------------
// Technique - Mirror - Render Coverflow Reflection
//--------------------------------------------------------------------------------------
technique RenderMirror
{
    pass Pass0
    {
        VertexShader = compile vs_2_0 CoverflowMirror_VS();
        PixelShader  = compile ps_2_0 CoverflowMirror_PS();
    }
}
