%% MARMARAY GRAND FINAL: THE COMPLETE SIMULATION
%  Guzergah: Halkali <-> Gebze (43 Durak - Tam Hat)
%  Mod: Slow Motion Cinematic (Ağır Çekim Sinematik)
%  Developer: Harun K. Korkmaz (AI Assisted)
%  Versiyon: 5.0 (Eksiksiz Tam Sürüm)

clc; clear; close all;
fprintf('================================================\n');
fprintf('MARMARAY TAM HAT SİMÜLASYONU YÜKLENİYOR...\n');
fprintf('================================================\n');

%% --- BÖLÜM 1: SİMÜLASYON AYARLARI (SLOW MOTION) ---
% Animasyon Hız Ayarları (Daha yavaş ve akıcı olması için)
animasyon_hizi = 2;       % Her 2. veriyi çiz (Düşük tutuldu)
sim_delay = 0.01;         % Her karede 10ms bekle (Ağır çekim etkisi)

% Araç Fizik Parametreleri (Hyundai Rotem)
tren_kutle_bos = 430000;  % 430 Ton
insan_kutle = 75;
motor_max_guc = 8000;     % kW
max_hiz_kmh = 90;
max_hiz_ms = max_hiz_kmh / 3.6;

% Dinamik ve Konfor
ivme_gaz = 0.8;           % m/s2
ivme_fren = 0.9;          % m/s2
istasyon_bekleme = 15;    % Saniye (Yolcu değişimi)

% Çevresel
g = 9.81;
rho = 1.225;
Cd = 0.8;
On_alan = 11;
disk_sicaklik = 25;       % Başlangıç sıcaklığı

%% --- BÖLÜM 2: GÜZERGAH VE HARİTA (43 İSTASYON) ---
fprintf('>> 43 İstasyon ve 3D Harita verileri işleniyor...\n');

istasyonlar = {
    'Halkali', 'Mustafa Kemal', 'Kucukcekmece', 'Florya', 'Florya Akvaryum', ...
    'Yesilkoy', 'Yesilyurt', 'Atakoy', 'Bakirkoy', 'Yenimahalle', ...
    'Zeytinburnu', 'Kazlicesme', 'Yenikapi', 'Sirkeci', 'Uskudar', ...
    'Ayrilik Cesmesi', 'Sogutlucesme', 'Feneryolu', 'Goztepe', 'Erenkoy', ...
    'Suadiye', 'Bostanci', 'Kucukyali', 'Idealtepe', 'Sureyya Plaji', ...
    'Maltepe', 'Cevizli', 'Atalar', 'Basak', 'Kartal', ...
    'Yunus', 'Pendik', 'Kaynarca', 'Tersane', 'Guzelyali', ...
    'Aydintepe', 'Icmeler', 'Tuzla', 'Cayirova', 'Fatih', ...
    'Osmangazi', 'Darica', 'Gebze'
};
durak_sayisi = length(istasyonlar);

% İstasyon Konumlarını Rastgele Ama Mantıklı Üret
istasyon_konumlari = zeros(1, durak_sayisi);
current_loc = 0;
rng(101); % Sabit harita için seed

for i = 2:durak_sayisi
    dist_next = 1200 + 1000 * rand(); 
    if i == 15, dist_next = 3500; end % Tüp Geçit (Sirkeci-Üsküdar arası uzun)
    current_loc = current_loc + dist_next;
    istasyon_konumlari(i) = current_loc;
end

hat_uzunlugu = istasyon_konumlari(end) + 1000;

% 3D Koordinat Sistemi (XYZ Mapping)
ds = 50; % Harita çözünürlüğü
s_map = 0:ds:hat_uzunlugu;
path_x = s_map;
path_y = 4000 * sin(s_map / 15000); % Y ekseni kıvrımları
path_z = zeros(size(s_map));

% Tüp Geçit Derinliği (Deniz Altı)
tup_giris = istasyon_konumlari(14) + 200; 
tup_cikis = istasyon_konumlari(15) - 200;

for k = 1:length(s_map)
    if s_map(k) > tup_giris && s_map(k) < tup_cikis
        depth_val = sin((s_map(k) - tup_giris)/(tup_cikis-tup_giris) * pi);
        path_z(k) = -60 * depth_val; % 60 metre derinlik
    end
end

%% --- BÖLÜM 3: FİZİK MOTORU (PRE-CALCULATION) ---
fprintf('>> Fizik motoru tüm seferi hesaplıyor (Bu işlem 3-5 saniye sürebilir)...\n');

dt = 0.2; % Zaman adımı
t = 0; x = 0; v = 0;
mevcut_yolcu = 1000;
next_idx = 2; 
wait_timer = 0;
state = 1; % 1:Gaz, 2:Sabit, 3:Fren, 4:Bekle

% Veri Kayıt
data.time = []; data.pos = []; data.vel = []; 
data.acc = []; data.power = []; data.temp = []; 
data.state = []; data.pass = []; data.next = [];

while next_idx <= durak_sayisi
    target_x = istasyon_konumlari(next_idx);
    dist_to_go = target_x - x;
    brake_dist = (v^2) / (2 * ivme_fren);
    
    % --- Durum Makinesi (State Machine) ---
    if state == 4 % İstasyonda Bekleme
        v = 0; acc = 0;
        wait_timer = wait_timer + dt;
        if wait_timer >= istasyon_bekleme
            state = 1; wait_timer = 0; % Kalkış
            next_idx = next_idx + 1;
            if next_idx > durak_sayisi, break; end
        end
        
    elseif dist_to_go <= brake_dist + 10 % Frenleme Bölgesi
        state = 3;
        req_dec = -(v^2) / (2 * dist_to_go);
        acc = min(req_dec, -0.5); 
        
        if v < 0.2 && dist_to_go < 5 % Durdu
            v = 0; acc = 0; state = 4;
            % Yolcu Simülasyonu
            if next_idx == 13 || next_idx == 17 
                mevcut_yolcu = min(4500, mevcut_yolcu + 800);
            else
                mevcut_yolcu = max(0, mevcut_yolcu + randi([-300, 300]));
            end
        end
        
    elseif v < max_hiz_ms % Hızlanma
        state = 1; acc = ivme_gaz;
    else % Sabit Hız
        state = 2; acc = 0; v = max_hiz_ms;
    end
    
    % Fiziksel İlerletme
    v = v + acc * dt; if v < 0, v = 0; end
    x = x + v * dt; t = t + dt;
    
    % Eğim ve Kuvvetler
    [~, map_i] = min(abs(s_map - x));
    if map_i < length(s_map)
        dz = path_z(map_i+1) - path_z(map_i);
        theta = atan2(dz, ds);
    else
        theta = 0;
    end
    
    total_m = tren_kutle_bos + mevcut_yolcu * insan_kutle;
    F_res = 0.5*rho*v^2*Cd*On_alan + total_m*g*0.002 + total_m*g*sin(theta);
    F_net = total_m * acc;
    F_trac = F_net + F_res;
    
    % Termal (Fren Isınması)
    if acc < -0.1, disk_sicaklik = disk_sicaklik + 0.3*abs(acc)*dt;
    else, disk_sicaklik = disk_sicaklik - 0.05*(1+v/20)*dt; end
    if disk_sicaklik < 25, disk_sicaklik = 25; end
    
    % Kayıt
    data.time(end+1) = t; data.pos(end+1) = x; data.vel(end+1) = v*3.6;
    data.acc(end+1) = acc; data.power(end+1) = F_trac*v/1000;
    data.temp(end+1) = disk_sicaklik; data.state(end+1) = state;
    data.pass(end+1) = mevcut_yolcu; data.next(end+1) = min(next_idx, durak_sayisi);
end

fprintf('>> Hesaplama Bitti. 2D Raporlar oluşturuluyor...\n');

%% --- BÖLÜM 4: 2D MÜHENDİSLİK GRAFİKLERİ ---
f_eng = figure('Name', 'Marmaray Mühendislik Analizi', 'Color', 'white', 'Position', [50, 50, 800, 600]);

subplot(3,1,1); 
plot(data.pos/1000, data.vel, 'b'); 
title('Hız Profili (Halkalı - Gebze)'); ylabel('km/h'); grid on;
xline(istasyon_konumlari/1000, 'k:', 'Alpha', 0.2);

subplot(3,1,2); 
plot(data.pos/1000, data.power, 'r'); 
title('Güç Tüketimi (kW)'); grid on; 
yline(0, 'k');

subplot(3,1,3); 
plot(data.pos/1000, data.temp, 'Color', [0.8 0.4 0]); 
title('Fren Sıcaklığı (°C)'); xlabel('Mesafe (km)'); grid on;

%% --- BÖLÜM 5: 3D SİNEMATİK ANİMASYON (SLOW MOTION) ---
fprintf('>> 3D Pencere açılıyor... Oynatma başlıyor...\n');
pause(2); % Kullanıcı grafikleri görsün diye bekle

f_anim = figure('Name', 'MARMARAY 3D SİNEMATİK İZLEME', 'Color', 'k', 'Position', [100, 100, 1200, 700]);

% --- 3D Sahne Kurulumu ---
ax3 = subplot(4,4, [1 2 3 5 6 7 9 10 11 13 14 15]);
hold on; axis equal; grid on; box on;
set(ax3, 'Color', [0.05 0.05 0.1], 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
view(3); xlabel('X'); ylabel('Y'); zlabel('Z');

% Rayları Çiz (Derinliğe göre renkli)
surface([path_x; path_x], [path_y; path_y], [path_z; path_z], ...
    [path_z; path_z], 'FaceColor', 'no', 'EdgeColor', 'interp', 'LineWidth', 2);
colormap(ax3, 'jet');

% Deniz Yüzeyi (Mavi Alan)
x_sea = [tup_giris-2000 tup_cikis+2000 tup_cikis+2000 tup_giris-2000];
y_sea = [-5000 -5000 5000 5000];
z_sea = [0 0 0 0];
fill3(x_sea, y_sea, z_sea, 'c', 'FaceAlpha', 0.15, 'EdgeColor', 'none');

% İstasyon Noktaları
plot3(path_x(1), path_y(1), path_z(1), 'wo', 'MarkerSize', 5);
for k = 1:durak_sayisi
    d_x = istasyon_konumlari(k);
    [~, ix] = min(abs(path_x - d_x));
    plot3(path_x(ix), path_y(ix), path_z(ix), 'w.');
    % Sadece önemli istasyon adları
    if ismember(k, [1, 9, 13, 14, 15, 17, 22, 31, 43])
        text(path_x(ix), path_y(ix), path_z(ix)+100, istasyonlar{k}, ...
            'Color', 'y', 'FontSize', 8, 'FontWeight', 'bold');
    end
end

% Hareketli Tren Objeleri
h_train = plot3(0,0,0, 's', 'MarkerSize', 12, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'w');
h_stop_light = plot3(0,0,0, 'r.', 'MarkerSize', 15, 'Visible', 'off');

% --- Dashboard Kurulumu ---
ax_spd = subplot(4,4,4); axis off;
text(0.5, 0.5, '0', 'Color', 'w', 'FontSize', 28, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(0.5, 0.2, 'km/h', 'Color', 'c', 'HorizontalAlignment', 'center');
h_txt_spd = findobj(ax_spd, 'Type', 'Text'); h_txt_spd = h_txt_spd(2);

ax_pwr = subplot(4,4,8);
h_bar_pwr = bar(1, 0, 'r'); ylim([-4000 8000]); xlim([0.5 1.5]);
set(gca,'Color','k','XColor','none','YColor','w'); title('GÜÇ', 'Color', 'w');

ax_inf = subplot(4,4,16); axis off;
h_txt_inf = text(0, 0.5, '', 'Color', 'g', 'FontSize', 9, 'FontName', 'Courier');

% --- OYNATMA DÖNGÜSÜ ---
len_sim = length(data.time);
fprintf('>> Simülasyon Oynatılıyor (Slow Motion)...\n');

for i = 1:animasyon_hizi:len_sim
    if ~isvalid(f_anim), break; end
    
    cur_x = data.pos(i);
    [~, m_idx] = min(abs(path_x - cur_x));
    tx = path_x(m_idx); ty = path_y(m_idx); tz = path_z(m_idx);
    
    % Treni Güncelle
    set(h_train, 'XData', tx, 'YData', ty, 'ZData', tz);
    
    st = data.state(i);
    % Durum Renkleri
    if st == 3 % Fren
        set(h_train, 'MarkerFaceColor', 'r');
        set(h_stop_light, 'XData', tx, 'YData', ty, 'ZData', tz+10, 'Visible', 'on');
    elseif st == 4 % Durak
        set(h_train, 'MarkerFaceColor', 'b');
        set(h_stop_light, 'Visible', 'off');
    else % Gaz
        set(h_train, 'MarkerFaceColor', 'g');
        set(h_stop_light, 'Visible', 'off');
    end
    
    % Akıllı Kamera (Zoom Logic)
    set(ax3, 'XLim', [tx-3000 tx+5000], 'YLim', [ty-3000 ty+3000]);
    if st == 4
        view(ax3, 90 + tx/2000, 10); % Zoom In (İstasyonda)
    else
        view(ax3, 45 + tx/3000, 40); % Geniş Açı (Yolda)
    end
    
    % Dashboard
    set(h_txt_spd, 'String', sprintf('%.0f', data.vel(i)));
    set(h_bar_pwr, 'YData', data.power(i));
    
    next_id = data.next(i);
    rem = istasyon_konumlari(next_id) - cur_x;
    d_str = "SEYİR"; if st==3, d_str="FREN"; elseif st==4, d_str="DURAK"; end
    
    set(h_txt_inf, 'String', sprintf('MOD: %s\nHedef: %s\nMesafe: %.0f m\nIsı: %.1f C', ...
        d_str, istasyonlar{next_id}, rem, data.temp(i)));
    
    drawnow;
    pause(sim_delay); % YAVAŞLATMA BURADA GERÇEKLEŞİYOR
end

fprintf('SEFER TAMAMLANDI. GEBZE''YE HOŞGELDİNİZ.\n');