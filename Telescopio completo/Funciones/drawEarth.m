function [hLight1, hLight2, hLight3] = drawEarth(longlat, ax)
    earth = flipud(imread("world.topo.bathy.200406.3x5400x2700.jpg"));
    cloud = flipud(imread("fair_clouds_8k.jpg")); %https://www.shadedrelief.com/natural3/pages/clouds.html
    cloud = imresize(cloud, [2048 4096]);
    spec = flipud(imread("2k_earth_specular_map.tif")); %https://www.solarsystemscope.com/textures/

    hold(ax, 'on')

    [x,y,z] = sphere(50);
    sEarth = surface(ax, x, y, z);
    sCloud = surface(ax, x*1.01, y*1.01, z*1.01);
    sAtm = surface(ax, x*1.025, y*1.025, z*1.03);
    sSpec = surface(ax, x*1.0001, y*1.0001, z*1.0001);

    ax.CameraViewAngleMode = 'manual';
    ax.CameraViewAngle = 5.2;

    rotate3d(ax, 'on')

    [xp,yp,zp] = sph2cart(longlat(1)*pi/180, longlat(2)*pi/180, 1);
    plot3(ax, xp, yp, zp, 'r.', 'MarkerSize', 10)

    colormap(ax, gray)

    sEarth.FaceColor = 'texturemap';
    sEarth.CData = earth;
    sEarth.EdgeColor = 'none';
    sEarth.FaceLighting = 'gouraud';
    sEarth.AmbientStrength = 0.1;
    sEarth.DiffuseStrength = 1.0;
    sEarth.SpecularStrength = 0.0;
    sEarth.SpecularExponent = 10;

    sCloud.FaceColor = 'texturemap';
    sCloud.CData = cloud;
    sCloud.EdgeColor = 'none';
    sCloud.FaceLighting = 'flat';
    sCloud.AmbientStrength = 0.1;
    sCloud.DiffuseStrength = 1.0;
    sCloud.SpecularStrength = 0.0;
    sCloud.SpecularExponent = 10;
    sCloud.FaceAlpha = 'texturemap';
    sCloud.AlphaData = double(cloud);

    sAtm.FaceColor = [135 206 250] / 255;
    sAtm.EdgeColor = 'none';
    sAtm.FaceLighting = 'flat';
    sAtm.AmbientStrength = 0.1;
    sAtm.DiffuseStrength = 1.0;
    sAtm.SpecularStrength = 0.0;
    sAtm.SpecularExponent = 10;
    sAtm.FaceAlpha = 0;

    sSpec.FaceColor      = [1 1 1];          % white = neutral color for specular
    sSpec.EdgeColor      = 'none';
    sSpec.FaceLighting   = 'gouraud';
    sSpec.AmbientStrength  = 0.0;
    sSpec.DiffuseStrength  = 0.0;            % no diffuse — specular only
    sSpec.SpecularStrength = 0.5;            % full specularity
    sSpec.SpecularExponent = 30;             % tight highlight
    sSpec.FaceAlpha      = 'texturemap';
    sSpec.AlphaData      = double(spec(:,:,1))/5;  % ocean = visible, land = invisible

    hLight1 = light(ax, 'Position', [xp yp zp], 'Color', [1 1 1]);
    hLight2 = light(ax, 'Position', [xp yp zp], 'Color', [1 1 1]);
    hLight3 = light(ax, 'Position', [xp yp zp], 'Color', [1 1 1]);

    axis(ax, 'equal', 'off')
    view(ax, 80 + longlat(1), 10)
    ax.DataAspectRatio = [1 1 1];
    ax.DataAspectRatioMode = 'manual';
    ax.PlotBoxAspectRatio = [1 1 1];
    ax.PlotBoxAspectRatioMode = 'manual';
    ax.XLimMode = 'manual';
    ax.YLimMode = 'manual';
    ax.ZLimMode = 'manual';
    ax.XLim = [-1.1 1.1];
    ax.YLim = [-1.1 1.1];
    ax.ZLim = [-1.1 1.1];
end