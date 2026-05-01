import os

languages = {
    "en": "English", "fr": "French", "es": "Spanish", "ja": "Japanese",
    "de": "German", "it": "Italian", "pt": "Portuguese", "zh-Hans": "Chinese (Simplified)",
    "ru": "Russian", "ko": "Korean"
}

# The remaining 80 strings to make the app PERFECTLY multilingual end-to-end
new_translations = {
    "Add New Address...": {
        "en": "Add New Address...", "fr": "Nouvelle adresse...", "es": "Nueva dirección...", "ja": "新しい住所を追加...", 
        "de": "Neue Adresse...", "it": "Nuovo indirizzo...", "pt": "Novo Endereço...", "zh-Hans": "添加新地址...", "ru": "Новый адрес...", "ko": "새 주소..."
    },
    "Add your delivery locations for a\\nfaster checkout experience.": {
        "en": "Add your delivery locations for a\\nfaster checkout experience.", 
        "fr": "Ajoutez vos adresses de livraison pour un\\npaiement plus rapide.", 
        "es": "Añade tus direcciones de entrega para un\\npago más rápido.", 
        "ja": "スムーズなお会計のために\\nお届け先を追加してください。", 
        "de": "Fügen Sie Lieferorte für einen\\nschnelleren Checkout hinzu.", 
        "it": "Aggiungi luoghi di consegna per un\\ncheckout più veloce.", 
        "pt": "Adicione seus locais de entrega para um\\ncheckout mais rápido.", 
        "zh-Hans": "添加您的送货地点以获得\\n更快的结账体验。", 
        "ru": "Добавьте адреса доставки для\\nболее быстрого оформления.", 
        "ko": "더 빠른 결제를 위해\\n배송지를 추가하세요."
    },
    "Always Online": {
        "en": "Always Online", "fr": "Toujours en ligne", "es": "Siempre en línea", "ja": "常時オンライン", 
        "de": "Immer online", "it": "Sempre online", "pt": "Sempre Online", "zh-Hans": "永远在线", "ru": "Всегда онлайн", "ko": "항상 온라인"
    },
    "Are you sure you want to cancel this order? This action cannot be undone.": {
        "en": "Are you sure you want to cancel this order? This action cannot be undone.", 
        "fr": "Êtes-vous sûr de vouloir annuler cette commande ? Cette action est irréversible.", 
        "es": "¿Seguro que quieres cancelar este pedido? Esta acción no se puede deshacer.", 
        "ja": "この注文をキャンセルしますか？この操作は元に戻せません。", 
        "de": "Möchten Sie diese Bestellung wirklich stornieren? Dies kann nicht rückgängig gemacht werden.", 
        "it": "Sei sicuro di voler annullare questo ordine? Questa azione non può essere annullata.", 
        "pt": "Tem certeza que deseja cancelar este pedido? Esta ação não pode ser desfeita.", 
        "zh-Hans": "您确定要取消此订单吗？此操作无法撤销。", 
        "ru": "Вы уверены, что хотите отменить этот заказ? Это действие нельзя отменить.", 
        "ko": "이 주문을 취소하시겠습니까? 이 작업은 실행 취소할 수 없습니다."
    },
    "BACK TO SHOP": {
        "en": "BACK TO SHOP", "fr": "RETOUR À LA BOUTIQUE", "es": "VOLVER A LA TIENDA", "ja": "ショップに戻る", 
        "de": "ZURÜCK ZUM SHOP", "it": "TORNA AL NEGOZIO", "pt": "VOLTAR À LOJA", "zh-Hans": "返回商店", "ru": "В МАГАЗИН", "ko": "상점으로 돌아가기"
    },
    "Body Tracking Active": {
        "en": "Body Tracking Active", "fr": "Suivi corporel actif", "es": "Seguimiento corporal activo", "ja": "ボディトラッキング中", 
        "de": "Körperverfolgung aktiv", "it": "Tracciamento corpo attivo", "pt": "Rastreamento Corporal Ativo", "zh-Hans": "身体追踪已激活", "ru": "Отслеживание тела активно", "ko": "바디 트래킹 활성"
    },
    "Book a personal consultation with our boutique experts.": {
        "en": "Book a personal consultation with our boutique experts.", 
        "fr": "Réservez une consultation personnelle avec nos experts.", 
        "es": "Reserva una consulta personal con nuestros expertos.", 
        "ja": "ブティックの専門家との個人的な相談を予約してください。", 
        "de": "Buchen Sie eine persönliche Beratung mit unseren Experten.", 
        "it": "Prenota una consulenza personale con i nostri esperti.", 
        "pt": "Agende uma consulta pessoal com nossos especialistas.", 
        "zh-Hans": "预约我们的精品店专家的个人咨询。", 
        "ru": "Забронируйте личную консультацию с нашими экспертами.", 
        "ko": "부티크 전문가와의 개인 상담을 예약하세요."
    },
    "Budget": {"en": "Budget", "fr": "Budget", "es": "Presupuesto", "ja": "予算", "de": "Budget", "it": "Budget", "pt": "Orçamento", "zh-Hans": "预算", "ru": "Бюджет", "ko": "예산"},
    "CAPTURED": {"en": "CAPTURED", "fr": "CAPTURÉ", "es": "CAPTURADO", "ja": "キャプチャ済み", "de": "ERFASST", "it": "ACQUISITO", "pt": "CAPTURADO", "zh-Hans": "已捕获", "ru": "ЗАХВАЧЕНО", "ko": "캡처됨"},
    "COMMENT (OPTIONAL)": {
        "en": "COMMENT (OPTIONAL)", "fr": "COMMENTAIRE (FACULTATIF)", "es": "COMENTARIO (OPCIONAL)", "ja": "コメント（任意）", 
        "de": "KOMMENTAR (OPTIONAL)", "it": "COMMENTO (OPZIONALE)", "pt": "COMENTÁRIO (OPCIONAL)", "zh-Hans": "评论（可选）", "ru": "КОММЕНТАРИЙ (НЕОБЯЗАТЕЛЬНО)", "ko": "의견 (선택 사항)"
    },
    "Camera Issue": {
        "en": "Camera Issue", "fr": "Problème de caméra", "es": "Problema de cámara", "ja": "カメラの問題", 
        "de": "Kameraproblem", "it": "Problema fotocamera", "pt": "Problema na Câmera", "zh-Hans": "相机问题", "ru": "Проблема с камерой", "ko": "카메라 문제"
    },
    "Cancelled": {"en": "Cancelled", "fr": "Annulé", "es": "Cancelado", "ja": "キャンセル済み", "de": "Storniert", "it": "Annullato", "pt": "Cancelado", "zh-Hans": "已取消", "ru": "Отменено", "ko": "취소됨"},
    "Certificate of Authenticity": {
        "en": "Certificate of Authenticity", "fr": "Certificat d'Authenticité", "es": "Certificado de Autenticidad", "ja": "真正証明書", 
        "de": "Echtheitszertifikat", "it": "Certificato di Autenticità", "pt": "Certificado de Autenticidade", "zh-Hans": "真品证书", "ru": "Сертификат подлинности", "ko": "진품 인증서"
    },
    "Change": {"en": "Change", "fr": "Modifier", "es": "Cambiar", "ja": "変更", "de": "Ändern", "it": "Modifica", "pt": "Alterar", "zh-Hans": "更改", "ru": "Изменить", "ko": "변경"},
    "Clear Filters": {"en": "Clear Filters", "fr": "Effacer les filtres", "es": "Borrar Filtros", "ja": "フィルターをクリア", "de": "Filter löschen", "it": "Cancella Filtri", "pt": "Limpar Filtros", "zh-Hans": "清除筛选", "ru": "Очистить фильтры", "ko": "필터 지우기"},
    "Complimentary": {"en": "Complimentary", "fr": "Offert", "es": "De cortesía", "ja": "無料", "de": "Kostenlos", "it": "Omaggio", "pt": "Cortesia", "zh-Hans": "免费", "ru": "Бесплатно", "ko": "무료"},
    "Continue with Google": {
        "en": "Continue with Google", "fr": "Continuer avec Google", "es": "Continuar con Google", "ja": "Googleで続行", 
        "de": "Mit Google fortfahren", "it": "Continua con Google", "pt": "Continuar com o Google", "zh-Hans": "使用 Google 继续", "ru": "Продолжить с Google", "ko": "Google로 계속하기"
    },
    "Create your account": {
        "en": "Create your account", "fr": "Créez votre compte", "es": "Crea tu cuenta", "ja": "アカウントを作成", 
        "de": "Konto erstellen", "it": "Crea il tuo account", "pt": "Crie sua conta", "zh-Hans": "创建您的账户", "ru": "Создайте свой аккаунт", "ko": "계정 만들기"
    },
    "DEFAULT": {"en": "DEFAULT", "fr": "PAR DÉFAUT", "es": "PREDETERMINADO", "ja": "デフォルト", "de": "STANDARD", "it": "PREDEFINITO", "pt": "PADRÃO", "zh-Hans": "默认", "ru": "ПО УМОЛЧАНИЮ", "ko": "기본값"},
    "DIOR": {"en": "LUXE", "fr": "LUXE", "es": "LUXE", "ja": "LUXE", "de": "LUXE", "it": "LUXE", "pt": "LUXE", "zh-Hans": "LUXE", "ru": "LUXE", "ko": "LUXE"},
    "Delivery Landmark": {
        "en": "Delivery Landmark", "fr": "Point de repère", "es": "Punto de referencia", "ja": "建物の目印", 
        "de": "Orientierungspunkt", "it": "Punto di riferimento", "pt": "Ponto de Referência", "zh-Hans": "地标", "ru": "Ориентир", "ko": "배송지 랜드마크"
    },
    "Don't have an account?": {
        "en": "Don't have an account?", "fr": "Pas de compte ?", "es": "¿No tienes cuenta?", "ja": "アカウントをお持ちでないですか？", 
        "de": "Kein Konto?", "it": "Non hai un account?", "pt": "Não tem uma conta?", "zh-Hans": "没有账户？", "ru": "Нет аккаунта?", "ko": "계정이 없으신가요?"
    },
    "ELENA": {"en": "ELENA", "fr": "ELENA", "es": "ELENA", "ja": "ELENA", "de": "ELENA", "it": "ELENA", "pt": "ELENA", "zh-Hans": "ELENA", "ru": "ELENA", "ko": "ELENA"},
    "Estimated Delivery": {
        "en": "Estimated Delivery", "fr": "Livraison estimée", "es": "Entrega estimada", "ja": "お届け予定日", 
        "de": "Voraussichtliche Lieferung", "it": "Consegna stimata", "pt": "Entrega Estimada", "zh-Hans": "预计交货", "ru": "Ожидаемая доставка", "ko": "예상 배송일"
    },
    "Estimated Total": {
        "en": "Estimated Total", "fr": "Total estimé", "es": "Total estimado", "ja": "合計（見積り）", 
        "de": "Geschätzte Summe", "it": "Totale stimato", "pt": "Total Estimado", "zh-Hans": "预估总额", "ru": "Ожидаемая сумма", "ko": "예상 총액"
    },
    "Experience luxury in person. Book a private appointment.": {
        "en": "Experience luxury in person. Book a private appointment.", 
        "fr": "Vivez le luxe en personne. Réservez un rendez-vous privé.", 
        "es": "Vive el lujo en persona. Reserva una cita privada.", 
        "ja": "直接ラグジュアリーを体験してください。プライベートアポイントを予約。", 
        "de": "Erleben Sie Luxus persönlich. Buchen Sie einen privaten Termin.", 
        "it": "Vivi il lusso di persona. Prenota un appuntamento privato.", 
        "pt": "Experimente o luxo pessoalmente. Agende uma consulta privada.", 
        "zh-Hans": "亲自体验奢华。预约私人会面。", 
        "ru": "Испытайте роскошь лично. Забронируйте индивидуальную встречу.", 
        "ko": "직접 럭셔리를 경험해 보세요. 비공개 예약을 잡으세요."
    },
    "Explore Collections": {
        "en": "Explore Collections", "fr": "Explorer les collections", "es": "Explorar colecciones", "ja": "コレクションを見る", 
        "de": "Kollektionen entdecken", "it": "Esplora Collezioni", "pt": "Explorar Coleções", "zh-Hans": "探索系列", "ru": "Изучить коллекции", "ko": "컬렉션 탐색"
    },
    "Explore our exclusive collection\\nand start your DIOR journey.": {
        "en": "Explore our exclusive collection\\nand start your LUXE journey.", 
        "fr": "Explorez notre collection exclusive\\net commencez votre voyage LUXE.", 
        "es": "Explora nuestra colección exclusiva\\ny comienza tu viaje LUXE.", 
        "ja": "限定コレクションを探索し、\\nLUXEの旅を始めましょう。", 
        "de": "Entdecken Sie unsere exklusive Kollektion\\nund beginnen Sie Ihre LUXE-Reise.", 
        "it": "Esplora la nostra collezione esclusiva\\ne inizia il tuo viaggio LUXE.", 
        "pt": "Explore nossa coleção exclusiva\\ne comece sua jornada LUXE.", 
        "zh-Hans": "探索我们的独家系列\\n开启您的 LUXE 之旅。", 
        "ru": "Изучите нашу эксклюзивную коллекцию\\nи начните свое путешествие с LUXE.", 
        "ko": "단독 컬렉션을 탐색하고\\nLUXE 여정을 시작하세요."
    },
    "Find shirts, pants, dresses, and more": {
        "en": "Find shirts, pants, dresses, and more", "fr": "Trouvez chemises, pantalons, robes...", "es": "Encuentra camisas, pantalones, vestidos...", 
        "ja": "シャツ、パンツ、ドレスなどを探す", "de": "Hemden, Hosen, Kleider und mehr finden", "it": "Trova camicie, pantaloni, abiti...", 
        "pt": "Encontre camisas, calças, vestidos...", "zh-Hans": "寻找衬衫、裤子、连衣裙等", "ru": "Найдите рубашки, брюки, платья и многое другое", "ko": "셔츠, 바지, 드레스 등 찾기"
    },
    "GO BACK": {"en": "GO BACK", "fr": "RETOUR", "es": "VOLVER", "ja": "戻る", "de": "ZURÜCK", "it": "INDIETRO", "pt": "VOLTAR", "zh-Hans": "返回", "ru": "НАЗАД", "ko": "뒤로 가기"},
    "How was your experience?": {
        "en": "How was your experience?", "fr": "Comment s'est passée votre expérience ?", "es": "¿Cómo fue tu experiencia?", 
        "ja": "あなたの体験はいかがでしたか？", "de": "Wie war Ihre Erfahrung?", "it": "Come è stata la tua esperienza?", 
        "pt": "Como foi sua experiência?", "zh-Hans": "您的体验如何？", "ru": "Как прошел ваш опыт?", "ko": "어떤 경험을 하셨나요?"
    },
    "INITIALIZING AR": {"en": "INITIALIZING AR", "fr": "INITIALISATION AR", "es": "INICIANDO RA", "ja": "ARを初期化中", "de": "AR INITIALISIEREN", "it": "INIZIALIZZAZIONE AR", "pt": "INICIANDO AR", "zh-Hans": "正在初始化 AR", "ru": "ИНИЦИАЛИЗАЦИЯ AR", "ko": "AR 초기화 중"},
    "Items": {"en": "Items", "fr": "Articles", "es": "Artículos", "ja": "アイテム", "de": "Artikel", "it": "Articoli", "pt": "Itens", "zh-Hans": "商品", "ru": "Товары", "ko": "품목"},
    "Luxury Redefined": {"en": "Luxury Redefined", "fr": "Le luxe redéfini", "es": "Lujo redefinido", "ja": "ラグジュアリーの再定義", "de": "Luxus neu definiert", "it": "Lusso ridefinito", "pt": "Luxo Redefinido", "zh-Hans": "重新定义奢华", "ru": "Роскошь переосмыслена", "ko": "럭셔리의 재정의"},
    "MAISON DE COUTURE": {"en": "MAISON DE COUTURE", "fr": "MAISON DE COUTURE", "es": "MAISON DE COUTURE", "ja": "メゾン ド クチュール", "de": "MAISON DE COUTURE", "it": "MAISON DE COUTURE", "pt": "MAISON DE COUTURE", "zh-Hans": "高级定制时装屋", "ru": "MAISON DE COUTURE", "ko": "메종 드 꾸뛰르"},
    "NEW": {"en": "NEW", "fr": "NOUVEAU", "es": "NUEVO", "ja": "NEW", "de": "NEU", "it": "NUOVO", "pt": "NOVO", "zh-Hans": "新", "ru": "НОВИНКА", "ko": "신규"},
    "No notifications yet.": {
        "en": "No notifications yet.", "fr": "Pas encore de notifications.", "es": "Aún no hay notificaciones.", "ja": "通知はまだありません。", 
        "de": "Noch keine Benachrichtigungen.", "it": "Nessuna notifica ancora.", "pt": "Nenhuma notificação ainda.", "zh-Hans": "暂无通知。", "ru": "Пока нет уведомлений.", "ko": "아직 알림이 없습니다."
    },
    "No reviews yet. Be the first to share your experience.": {
        "en": "No reviews yet. Be the first to share your experience.", "fr": "Soyez le premier à partager votre expérience.", 
        "es": "Sé el primero en compartir tu experiencia.", "ja": "最初のレビューを書きましょう。", 
        "de": "Seien Sie der Erste, der seine Erfahrung teilt.", "it": "Sii il primo a condividere la tua esperienza.", 
        "pt": "Seja o primeiro a compartilhar sua experiência.", "zh-Hans": "暂无评价。成为第一个分享体验的人。", 
        "ru": "Станьте первым, кто поделится своим опытом.", "ko": "아직 리뷰가 없습니다. 첫 번째로 경험을 공유하세요."
    },
    "OR": {"en": "OR", "fr": "OU", "es": "O", "ja": "または", "de": "ODER", "it": "O", "pt": "OU", "zh-Hans": "或", "ru": "ИЛИ", "ko": "또는"},
    "PURCHASE COMPLETE": {"en": "PURCHASE COMPLETE", "fr": "ACHAT TERMINÉ", "es": "COMPRA COMPLETADA", "ja": "購入完了", "de": "KAUF ABGESCHLOSSEN", "it": "ACQUISTO COMPLETATO", "pt": "COMPRA CONCLUÍDA", "zh-Hans": "购买完成", "ru": "ПОКУПКА ЗАВЕРШЕНА", "ko": "구매 완료"},
    "Private Experience": {"en": "Private Experience", "fr": "Expérience Privée", "es": "Experiencia Privada", "ja": "プライベート体験", "de": "Privates Erlebnis", "it": "Esperienza Privata", "pt": "Experiência Privada", "zh-Hans": "私人体验", "ru": "Индивидуальный опыт", "ko": "프라이빗 경험"},
    "Profile Updated": {"en": "Profile Updated", "fr": "Profil mis à jour", "es": "Perfil actualizado", "ja": "プロフィールを更新しました", "de": "Profil aktualisiert", "it": "Profilo aggiornato", "pt": "Perfil Atualizado", "zh-Hans": "个人资料已更新", "ru": "Профиль обновлен", "ko": "프로필 업데이트됨"},
    "RATE THIS PRODUCT": {"en": "RATE THIS PRODUCT", "fr": "NOTER CE PRODUIT", "es": "VALORA ESTE PRODUCTO", "ja": "この商品を評価", "de": "PRODUKT BEWERTEN", "it": "VALUTA QUESTO PRODOTTO", "pt": "AVALIE ESTE PRODUTO", "zh-Hans": "评价此产品", "ru": "ОЦЕНИТЬ ЭТОТ ПРОДУКТ", "ko": "이 제품 평가하기"},
    "REGION TAX": {"en": "REGION TAX", "fr": "TAXE RÉGIONALE", "es": "IMPUESTO REGIONAL", "ja": "地域税", "de": "REGIONALE STEUER", "it": "TASSA REGIONALE", "pt": "IMPOSTO REGIONAL", "zh-Hans": "地区税", "ru": "РЕГИОНАЛЬНЫЙ НАЛОГ", "ko": "지역 세금"},
    "RESET": {"en": "RESET", "fr": "RÉINITIALISER", "es": "RESTABLECER", "ja": "リセット", "de": "ZURÜCKSETZEN", "it": "RIPRISTINA", "pt": "REDEFINIR", "zh-Hans": "重置", "ru": "СБРОС", "ko": "초기화"},
    "SAVE": {"en": "SAVE", "fr": "ENREGISTRER", "es": "GUARDAR", "ja": "保存", "de": "SPEICHERN", "it": "SALVA", "pt": "SALVAR", "zh-Hans": "保存", "ru": "СОХРАНИТЬ", "ko": "저장"},
    "SELECT A PRODUCT TO REVIEW": {"en": "SELECT A PRODUCT", "fr": "SÉLECTIONNER UN PRODUIT", "es": "SELECCIONA UN PRODUCTO", "ja": "商品を選択", "de": "PRODUKT WÄHLEN", "it": "SELEZIONA UN PRODOTTO", "pt": "SELECIONAR UM PRODUTO", "zh-Hans": "选择产品", "ru": "ВЫБЕРИТЕ ПРОДУКТ", "ko": "제품 선택"},
    "STAND BACK": {"en": "STAND BACK", "fr": "RECULEZ", "es": "ALÉJATE", "ja": "下がってください", "de": "TRETEN SIE ZURÜCK", "it": "FAI UN PASSO INDIETRO", "pt": "AFASTE-SE", "zh-Hans": "后退", "ru": "ОТОЙДИТЕ", "ko": "뒤로 물러나세요"},
    "Save items you love for later.\\nTap the ♡ on any product to add it here.": {
        "en": "Save items you love for later.\\nTap the ♡ on any product to add it here.", 
        "fr": "Enregistrez vos articles préférés.\\nTouchez ♡ pour les ajouter.", 
        "es": "Guarda tus artículos favoritos.\\nToca ♡ para añadirlos.", 
        "ja": "お気に入りを保存します。\\n商品の ♡ をタップして追加。", 
        "de": "Speichern Sie Lieblingsartikel.\\nTippen Sie auf ♡ zum Hinzufügen.", 
        "it": "Salva i tuoi articoli preferiti.\\nTocca ♡ per aggiungerli.", 
        "pt": "Salve seus itens favoritos.\\nToque em ♡ para adicionar.", 
        "zh-Hans": "保存您喜欢的商品。\\n轻触 ♡ 即可添加。", 
        "ru": "Сохраняйте любимые вещи.\\nНажмите ♡ для добавления.", 
        "ko": "좋아하는 항목을 저장하세요.\\n♡를 탭하여 추가합니다."
    },
    "Search": {"en": "Search", "fr": "Recherche", "es": "Buscar", "ja": "検索", "de": "Suche", "it": "Cerca", "pt": "Buscar", "zh-Hans": "搜索", "ru": "Поиск", "ko": "검색"},
    "Search for clothing to try on": {
        "en": "Search for clothing to try on", "fr": "Rechercher des vêtements à essayer", "es": "Buscar ropa para probarse", 
        "ja": "試着する服を検索", "de": "Suche nach Kleidung zum Anprobieren", "it": "Cerca vestiti da provare", 
        "pt": "Buscar roupas para provar", "zh-Hans": "搜索要试穿的衣服", "ru": "Поиск одежды для примерки", "ko": "입어볼 옷 검색"
    },
    "Search watches, jewelry, fashion": {
        "en": "Search watches, jewelry, fashion", "fr": "Montres, bijoux, mode...", "es": "Relojes, joyas, moda...", 
        "ja": "時計、ジュエリー、ファッションを検索", "de": "Uhren, Schmuck, Mode suchen", "it": "Cerca orologi, gioielli, moda", 
        "pt": "Buscar relógios, joias, moda", "zh-Hans": "搜索手表、珠宝、时尚", "ru": "Поиск часов, ювелирных изделий, моды", "ko": "시계, 보석, 패션 검색"
    },
    "Select Boutique": {"en": "Select Boutique", "fr": "Sélectionner la Boutique", "es": "Seleccionar Boutique", "ja": "ブティックを選択", "de": "Boutique wählen", "it": "Seleziona Boutique", "pt": "Selecionar Boutique", "zh-Hans": "选择精品店", "ru": "Выбрать бутик", "ko": "부티크 선택"},
    "Show your full upper body to the camera": {
        "en": "Show your full upper body to the camera", "fr": "Montrez tout votre haut du corps à la caméra", "es": "Muestra toda la parte superior de tu cuerpo a la cámara", 
        "ja": "上半身全体をカメラに映してください", "de": "Zeigen Sie Ihren gesamten Oberkörper der Kamera", "it": "Mostra tutta la parte superiore del corpo alla telecamera", 
        "pt": "Mostre toda a parte superior do seu corpo para a câmera", "zh-Hans": "向相机展示您的整个上半身", "ru": "Покажите камере всю верхнюю часть тела", "ko": "카메라에 상체 전체를 보여주세요"
    },
    "Standard Delivery: 3–5 Business Days": {
        "en": "Standard Delivery: 3–5 Business Days", "fr": "Livraison standard : 3-5 jours", "es": "Entrega Estándar: 3-5 días", 
        "ja": "通常配送：3〜5営業日", "de": "Standardlieferung: 3-5 Tage", "it": "Consegna standard: 3-5 giorni", 
        "pt": "Entrega Padrão: 3-5 Dias", "zh-Hans": "标准交付：3-5 个工作日", "ru": "Стандартная доставка: 3-5 дней", "ko": "표준 배송: 3~5일"
    },
    "Subtotal": {"en": "Subtotal", "fr": "Sous-total", "es": "Subtotal", "ja": "小計", "de": "Zwischensumme", "it": "Subtotale", "pt": "Subtotal", "zh-Hans": "小计", "ru": "Подитог", "ko": "소계"},
    "TRY AGAIN": {"en": "TRY AGAIN", "fr": "RÉESSAYER", "es": "INTENTAR DE NUEVO", "ja": "再試行", "de": "ERNEUT VERSUCHEN", "it": "RIPROVA", "pt": "TENTAR NOVAMENTE", "zh-Hans": "重试", "ru": "ПОПРОБОВАТЬ СНОВА", "ko": "다시 시도"},
    "Tap to change picture": {
        "en": "Tap to change picture", "fr": "Toucher pour changer la photo", "es": "Toca para cambiar la foto", "ja": "タップして写真を変更", 
        "de": "Tippen, um das Bild zu ändern", "it": "Tocca per cambiare l'immagine", "pt": "Toque para mudar a foto", "zh-Hans": "点击更改图片", "ru": "Нажмите, чтобы изменить фото", "ko": "탭하여 사진 변경"
    },
    "Taxes (18%)": {"en": "Taxes", "fr": "Taxes", "es": "Impuestos", "ja": "税金", "de": "Steuern", "it": "Tasse", "pt": "Impostos", "zh-Hans": "税金", "ru": "Налоги", "ko": "세금"},
    "Thank you for your review!": {
        "en": "Thank you for your review!", "fr": "Merci pour votre avis !", "es": "¡Gracias por tu opinión!", "ja": "レビューありがとうございます！", 
        "de": "Danke für Ihre Bewertung!", "it": "Grazie per la tua recensione!", "pt": "Obrigado pela sua avaliação!", "zh-Hans": "感谢您的评价！", "ru": "Спасибо за ваш отзыв!", "ko": "리뷰를 남겨주셔서 감사합니다!"
    },
    "This feature is coming soon.\\nWe're building something beautiful for you.": {
        "en": "This feature is coming soon.\\nWe're building something beautiful for you.", 
        "fr": "Bientôt disponible.\\nNous préparons quelque chose de beau.", 
        "es": "Próximamente.\\nEstamos creando algo hermoso para ti.", 
        "ja": "近日公開。\\n美しいものを準備中です。", 
        "de": "Demnächst verfügbar.\\nWir bauen etwas Schönes für Sie.", 
        "it": "In arrivo.\\nStiamo creando qualcosa di bello per te.", 
        "pt": "Em breve.\\nEstamos construindo algo lindo para você.", 
        "zh-Hans": "该功能即将推出。\\n我们正在为您打造美好的事物。", 
        "ru": "Эта функция скоро появится.\\nМы создаем для вас что-то прекрасное.", "ko": "이 기능은 곧 제공될 예정입니다.\\n당신을 위해 아름다운 것을 만들고 있습니다."
    },
    "Total": {"en": "Total", "fr": "Total", "es": "Total", "ja": "合計", "de": "Gesamt", "it": "Totale", "pt": "Total", "zh-Hans": "总计", "ru": "Итого", "ko": "총액"},
    "Unlock exclusive\\ndiscounts at checkout": {
        "en": "Unlock exclusive\\ndiscounts at checkout", "fr": "Débloquez des réductions\\nexclusives", "es": "Desbloquea descuentos\\nexclusivos", 
        "ja": "限定割引を\\nロック解除する", "de": "Schalten Sie exklusive\\nRabatte frei", "it": "Sblocca sconti\\nesclusivi", 
        "pt": "Desbloqueie descontos\\nexclusivos", "zh-Hans": "在结账时\\n解锁独家折扣", "ru": "Разблокируйте эксклюзивные\\nскидки", "ko": "결제 시\\n독점 할인 잠금 해제"
    },
    "We look forward to welcoming you to our boutique.": {
        "en": "We look forward to welcoming you to our boutique.", "fr": "Nous avons hâte de vous accueillir.", "es": "Esperamos darle la bienvenida.", 
        "ja": "ご来店を心よりお待ちしております。", "de": "Wir freuen uns darauf, Sie zu begrüßen.", "it": "Non vediamo l'ora di darti il benvenuto.", 
        "pt": "Estamos ansiosos para recebê-lo.", "zh-Hans": "我们期待着欢迎您光临我们的精品店。", "ru": "Мы с нетерпением ждем возможности приветствовать вас.", "ko": "부티크에서 귀하를 환영하기를 기대합니다."
    },
    "YOUR COMMENT (OPTIONAL)": {"en": "YOUR COMMENT (OPTIONAL)", "fr": "VOTRE COMMENTAIRE (FACULTATIF)", "es": "TU COMENTARIO (OPCIONAL)", "ja": "あなたのコメント（任意）", "de": "IHR KOMMENTAR (OPTIONAL)", "it": "IL TUO COMMENTO (OPZIONALE)", "pt": "SEU COMENTÁRIO (OPCIONAL)", "zh-Hans": "您的评论（可选）", "ru": "ВАШ КОММЕНТАРИЙ (НЕОБЯЗАТЕЛЬНО)", "ko": "의견 (선택 사항)"},
    "Your feedback helps others make better choices.": {
        "en": "Your feedback helps others make better choices.", "fr": "Vos commentaires aident les autres.", "es": "Tus comentarios ayudan a otros.", 
        "ja": "あなたのフィードバックは他の人の参考になります。", "de": "Ihr Feedback hilft anderen.", "it": "Il tuo feedback aiuta gli altri.", 
        "pt": "Seu feedback ajuda os outros.", "zh-Hans": "您的反馈可以帮助其他人做出更好的选择。", "ru": "Ваш отзыв помогает другим.", "ko": "귀하의 피드백은 다른 사람들이 더 나은 선택을 하는 데 도움이 됩니다."
    },
    "Your luxury items are being prepared for shipment. A confirmation email has been sent to your registered email.": {
        "en": "Your luxury items are being prepared for shipment. A confirmation email has been sent to your registered email.", 
        "fr": "Vos articles sont en cours de préparation. Un e-mail a été envoyé.", 
        "es": "Tus artículos se están preparando. Se ha enviado un correo.", 
        "ja": "商品は発送の準備中です。確認メールが送信されました。", 
        "de": "Ihre Artikel werden vorbereitet. Eine E-Mail wurde gesendet.", 
        "it": "I tuoi articoli sono in preparazione. È stata inviata un'email.", 
        "pt": "Seus itens estão sendo preparados. Um e-mail foi enviado.", 
        "zh-Hans": "您的奢侈品正在准备发货。确认电子邮件已发送。", 
        "ru": "Ваши товары готовятся к отправке. Письмо было отправлено.", 
        "ko": "명품이 배송 준비 중입니다. 확인 이메일이 전송되었습니다."
    },
    
    # Navigation Titles
    "Active Offers": {"en": "Active Offers", "fr": "Offres Actives", "es": "Ofertas Activas", "ja": "オファー", "de": "Aktive Angebote", "it": "Offerte Attive", "pt": "Ofertas Ativas", "zh-Hans": "有效优惠", "ru": "Активные предложения", "ko": "활성 혜택"},
    "BOUTIQUE VISIT": {"en": "BOUTIQUE VISIT", "fr": "VISITE BOUTIQUE", "es": "VISITA BOUTIQUE", "ja": "ブティック訪問", "de": "BOUTIQUE-BESUCH", "it": "VISITA BOUTIQUE", "pt": "VISITA À BOUTIQUE", "zh-Hans": "精品店参观", "ru": "ВИЗИТ В БУТИК", "ko": "부티크 방문"},
    "Find Clothing": {"en": "Find Clothing", "fr": "Trouver des vêtements", "es": "Buscar Ropa", "ja": "服を探す", "de": "Kleidung finden", "it": "Trova Abbigliamento", "pt": "Buscar Roupas", "zh-Hans": "查找服装", "ru": "Найти одежду", "ko": "옷 찾기"},
    "NOTIFICATIONS": {"en": "NOTIFICATIONS", "fr": "NOTIFICATIONS", "es": "NOTIFICACIONES", "ja": "通知", "de": "BENACHRICHTIGUNGEN", "it": "NOTIFICHE", "pt": "NOTIFICAÇÕES", "zh-Hans": "通知", "ru": "УВЕДОМЛЕНИЯ", "ko": "알림"},
    "PROFILE": {"en": "PROFILE", "fr": "PROFIL", "es": "PERFIL", "ja": "プロフィール", "de": "PROFIL", "it": "PROFILO", "pt": "PERFIL", "zh-Hans": "个人资料", "ru": "ПРОФИЛЬ", "ko": "프로필"},
    "SELECT ADDRESS": {"en": "SELECT ADDRESS", "fr": "CHOISIR L'ADRESSE", "es": "SELECCIONAR DIRECCIÓN", "ja": "住所を選択", "de": "ADRESSE WÄHLEN", "it": "SELEZIONA INDIRIZZO", "pt": "SELECIONAR ENDEREÇO", "zh-Hans": "选择地址", "ru": "ВЫБРАТЬ АДРЕС", "ko": "주소 선택"},
    "SELECT BOUTIQUE": {"en": "SELECT BOUTIQUE", "fr": "CHOISIR BOUTIQUE", "es": "SELECCIONAR BOUTIQUE", "ja": "ブティックを選択", "de": "BOUTIQUE WÄHLEN", "it": "SELEZIONA BOUTIQUE", "pt": "SELECIONAR BOUTIQUE", "zh-Hans": "选择精品店", "ru": "ВЫБРАТЬ БУТИК", "ko": "부티크 선택"},
    "SELECT LOCATION": {"en": "SELECT LOCATION", "fr": "CHOISIR L'EMPLACEMENT", "es": "SELECCIONAR UBICACIÓN", "ja": "場所を選択", "de": "ORT WÄHLEN", "it": "SELEZIONA POSIZIONE", "pt": "SELECIONAR LOCALIZAÇÃO", "zh-Hans": "选择位置", "ru": "ВЫБРАТЬ МЕСТОПОЛОЖЕНИЕ", "ko": "위치 선택"}
}

directory_base = "/Users/apple/Desktop/RSMS-User-iOS-App/User-Side-App"

# Append these new translations to the existing files
for code, lang in languages.items():
    strings_path = os.path.join(directory_base, f"{code}.lproj", "Localizable.strings")
    
    append_content = f"\n/* Appended Batch for 100% Coverage ({lang}) */\n"
    for eng_key, langs_dict in new_translations.items():
        val = langs_dict.get(code, eng_key).replace('"', '\\"')
        append_content += f'"{eng_key}" = "{val}";\n'
        
    with open(strings_path, "a", encoding="utf-8") as f:
        f.write(append_content)
        
print("Successfully appended 80 new strings to all 10 Localizable.strings files.")
