import os

languages = {
    "en": "English", "fr": "French", "es": "Spanish", "ja": "Japanese",
    "de": "German", "it": "Italian", "pt": "Portuguese", "zh-Hans": "Chinese (Simplified)",
    "ru": "Russian", "ko": "Korean"
}

translations = {
    # Core Tabs
    "Home": {"en": "Home", "fr": "Accueil", "es": "Inicio", "ja": "ホーム", "de": "Startseite", "it": "Home", "pt": "Início", "zh-Hans": "主页", "ru": "Главная", "ko": "홈"},
    "Shop": {"en": "Shop", "fr": "Boutique", "es": "Tienda", "ja": "ショップ", "de": "Shop", "it": "Negozio", "pt": "Loja", "zh-Hans": "商店", "ru": "Магазин", "ko": "상점"},
    "Cart": {"en": "Cart", "fr": "Panier", "es": "Cesta", "ja": "カート", "de": "Warenkorb", "it": "Carrello", "pt": "Carrinho", "zh-Hans": "购物车", "ru": "Корзина", "ko": "장바구니"},
    "Profile": {"en": "Profile", "fr": "Profil", "es": "Perfil", "ja": "プロフィール", "de": "Profil", "it": "Profilo", "pt": "Perfil", "zh-Hans": "个人资料", "ru": "Профиль", "ko": "프로필"},
    
    # Profile & Settings
    "MY DIOR": {"en": "LUXE", "fr": "LUXE", "es": "LUXE", "ja": "LUXE", "de": "LUXE", "it": "LUXE", "pt": "LUXE", "zh-Hans": "LUXE", "ru": "LUXE", "ko": "LUXE"},
    "Orders": {"en": "Orders", "fr": "Commandes", "es": "Pedidos", "ja": "注文履歴", "de": "Bestellungen", "it": "Ordini", "pt": "Pedidos", "zh-Hans": "订单", "ru": "Заказы", "ko": "주문"},
    "Wishlist": {"en": "Wishlist", "fr": "Favoris", "es": "Favoritos", "ja": "お気に入り", "de": "Wunschliste", "it": "Lista desideri", "pt": "Lista de Desejos", "zh-Hans": "心愿单", "ru": "Избранное", "ko": "위시리스트"},
    "Addresses": {"en": "Addresses", "fr": "Adresses", "es": "Direcciones", "ja": "住所", "de": "Adressen", "it": "Indirizzi", "pt": "Endereços", "zh-Hans": "地址", "ru": "Адреса", "ko": "주소"},
    "SHOPPING": {"en": "SHOPPING", "fr": "ACHATS", "es": "COMPRAS", "ja": "ショッピング", "de": "EINKAUFEN", "it": "ACQUISTI", "pt": "COMPRAS", "zh-Hans": "购物", "ru": "ПОКУПКИ", "ko": "쇼핑"},
    "My Orders": {"en": "My Orders", "fr": "Mes Commandes", "es": "Mis Pedidos", "ja": "注文履歴", "de": "Meine Bestellungen", "it": "I Miei Ordini", "pt": "Meus Pedidos", "zh-Hans": "我的订单", "ru": "Мои Заказы", "ko": "내 주문"},
    "Saved Addresses": {"en": "Saved Addresses", "fr": "Adresses Enregistrées", "es": "Direcciones Guardadas", "ja": "保存された住所", "de": "Gespeicherte Adressen", "it": "Indirizzi Salvati", "pt": "Endereços Salvos", "zh-Hans": "保存的地址", "ru": "Сохраненные Адреса", "ko": "저장된 주소"},
    "APPEARANCE": {"en": "APPEARANCE", "fr": "APPARENCE", "es": "APARIENCIA", "ja": "外観", "de": "ERSCHEINUNGSBILD", "it": "ASPETTO", "pt": "APARÊNCIA", "zh-Hans": "外观", "ru": "ВНЕШНИЙ ВИД", "ko": "외관"},
    "Theme": {"en": "Theme", "fr": "Thème", "es": "Tema", "ja": "テーマ", "de": "Design", "it": "Tema", "pt": "Tema", "zh-Hans": "主题", "ru": "Тема", "ko": "테마"},
    "Language & Region": {"en": "Language & Region", "fr": "Langue et Région", "es": "Idioma y Región", "ja": "言語と地域", "de": "Sprache & Region", "it": "Lingua e Regione", "pt": "Idioma e Região", "zh-Hans": "语言与地区", "ru": "Язык и Регион", "ko": "언어 및 지역"},
    "LOG OUT": {"en": "LOG OUT", "fr": "SE DÉCONNECTER", "es": "CERRAR SESIÓN", "ja": "ログアウト", "de": "ABMELDEN", "it": "ESCI", "pt": "SAIR", "zh-Hans": "登出", "ru": "ВЫЙТИ", "ko": "로그아웃"},
    "EDIT PROFILE": {"en": "EDIT PROFILE", "fr": "MODIFIER LE PROFIL", "es": "EDITAR PERFIL", "ja": "プロフィールを編集", "de": "PROFIL BEARBEITEN", "it": "MODIFICA PROFILO", "pt": "EDITAR PERFIL", "zh-Hans": "编辑资料", "ru": "РЕДАКТИРОВАТЬ ПРОФИЛЬ", "ko": "프로필 편집"},
    "JOIN DIOR": {"en": "JOIN LUXE", "fr": "REJOINDRE LUXE", "es": "UNIRSE A LUXE", "ja": "LUXEに参加", "de": "LUXE BEITRETEN", "it": "UNISCITI A LUXE", "pt": "JUNTE-SE À LUXE", "zh-Hans": "加入 LUXE", "ru": "ПРИСОЕДИНИТЬСЯ К LUXE", "ko": "LUXE 가입"},
    "SIGN IN": {"en": "SIGN IN", "fr": "SE CONNECTER", "es": "INICIAR SESIÓN", "ja": "サインイン", "de": "ANMELDEN", "it": "ACCEDI", "pt": "ENTRAR", "zh-Hans": "登录", "ru": "ВОЙТИ", "ko": "로그인"},
    "CREATE ACCOUNT": {"en": "CREATE ACCOUNT", "fr": "CRÉER UN COMPTE", "es": "CREAR CUENTA", "ja": "アカウントを作成", "de": "KONTO ERSTELLEN", "it": "CREA ACCOUNT", "pt": "CRIAR CONTA", "zh-Hans": "创建账户", "ru": "СОЗДАТЬ АККАУНТ", "ko": "계정 만들기"},

    # Checkout & Cart
    "Checkout": {"en": "Checkout", "fr": "Paiement", "es": "Pagar", "ja": "お会計", "de": "Kasse", "it": "Cassa", "pt": "Finalizar Compra", "zh-Hans": "结账", "ru": "Оформление заказа", "ko": "결제"},
    "Place Order": {"en": "Place Order", "fr": "Commander", "es": "Realizar Pedido", "ja": "注文を確定", "de": "Bestellung aufgeben", "it": "Effettua Ordine", "pt": "Fazer Pedido", "zh-Hans": "下订单", "ru": "Разместить Заказ", "ko": "주문하기"},
    "CHECKOUT": {"en": "CHECKOUT", "fr": "PAIEMENT", "es": "PAGO", "ja": "お会計", "de": "KASSE", "it": "CASSA", "pt": "FINALIZAR COMPRA", "zh-Hans": "结账", "ru": "ОФОРМЛЕНИЕ ЗАКАЗА", "ko": "결제"},
    "PROCEED TO CHECKOUT": {"en": "PROCEED TO CHECKOUT", "fr": "PASSER À LA CAISSE", "es": "PROCEDER AL PAGO", "ja": "レジに進む", "de": "ZUR KASSE GEHEN", "it": "PROCEDI ALLA CASSA", "pt": "PROSSEGUIR PARA PAGAMENTO", "zh-Hans": "去结账", "ru": "ПЕРЕЙТИ К ОФОРМЛЕНИЮ", "ko": "결제 진행"},
    "CART": {"en": "CART", "fr": "PANIER", "es": "CESTA", "ja": "カート", "de": "WARENKORB", "it": "CARRELLO", "pt": "CARRINHO", "zh-Hans": "购物车", "ru": "КОРЗИНА", "ko": "장바구니"},
    "SUBTOTAL": {"en": "SUBTOTAL", "fr": "SOUS-TOTAL", "es": "SUBTOTAL", "ja": "小計", "de": "ZWISCHENSUMME", "it": "SUBTOTALE", "pt": "SUBTOTAL", "zh-Hans": "小计", "ru": "ПОДИТОГ", "ko": "소계"},
    "TAX": {"en": "TAX", "fr": "TAXES", "es": "IMPUESTOS", "ja": "税金", "de": "STEUER", "it": "TASSE", "pt": "IMPOSTO", "zh-Hans": "税", "ru": "НАЛОГ", "ko": "세금"},
    "TOTAL AMOUNT": {"en": "TOTAL AMOUNT", "fr": "MONTANT TOTAL", "es": "CANTIDAD TOTAL", "ja": "合計金額", "de": "GESAMTBETRAG", "it": "IMPORTO TOTALE", "pt": "VALOR TOTAL", "zh-Hans": "总计", "ru": "ОБЩАЯ СУММА", "ko": "총액"},
    "Delivery Fee": {"en": "Delivery Fee", "fr": "Frais de livraison", "es": "Gastos de envío", "ja": "配送料", "de": "Liefergebühr", "it": "Spese di consegna", "pt": "Taxa de Entrega", "zh-Hans": "运费", "ru": "Стоимость доставки", "ko": "배송비"},
    "Calculating...": {"en": "Calculating...", "fr": "Calcul en cours...", "es": "Calculando...", "ja": "計算中...", "de": "Berechnung...", "it": "Calcolo...", "pt": "Calculando...", "zh-Hans": "计算中...", "ru": "Вычисление...", "ko": "계산 중..."},
    "Added to Cart": {"en": "Added to Cart", "fr": "Ajouté au panier", "es": "Añadido a la cesta", "ja": "カートに追加しました", "de": "Zum Warenkorb hinzugefügt", "it": "Aggiunto al carrello", "pt": "Adicionado ao Carrinho", "zh-Hans": "已加入购物车", "ru": "Добавлено в корзину", "ko": "장바구니에 추가됨"},
    "ADD TO CART": {"en": "ADD TO CART", "fr": "AJOUTER AU PANIER", "es": "AÑADIR A LA CESTA", "ja": "カートに入れる", "de": "IN DEN WARENKORB", "it": "AGGIUNGI AL CARRELLO", "pt": "ADICIONAR AO CARRINHO", "zh-Hans": "加入购物车", "ru": "В КОРЗИНУ", "ko": "장바구니에 담기"},
    "BUY NOW": {"en": "BUY NOW", "fr": "ACHETER MAINTENANT", "es": "COMPRAR AHORA", "ja": "今すぐ購入", "de": "JETZT KAUFEN", "it": "COMPRA ORA", "pt": "COMPRE AGORA", "zh-Hans": "立即购买", "ru": "КУПИТЬ СЕЙЧАС", "ko": "지금 구매"},
    "Your bag is empty": {"en": "Your bag is empty", "fr": "Votre panier est vide", "es": "Tu cesta está vacía", "ja": "カートは空です", "de": "Ihre Tasche ist leer", "it": "La tua borsa è vuota", "pt": "Sua bolsa está vazia", "zh-Hans": "您的购物袋是空的", "ru": "Ваша корзина пуста", "ko": "장바구니가 비어 있습니다"},
    "Browse the Shop tab to place an order": {"en": "Browse the Shop tab to place an order", "fr": "Parcourez la boutique pour commander", "es": "Explora la Tienda para pedir", "ja": "ショップから商品を選んでください", "de": "Durchsuchen Sie den Shop", "it": "Sfoglia il negozio per ordinare", "pt": "Navegue na loja para fazer um pedido", "zh-Hans": "浏览商店下订单", "ru": "Просмотрите магазин для заказа", "ko": "상점 탭을 탐색하여 주문하세요"},
    
    # Orders
    "MY ORDERS": {"en": "MY ORDERS", "fr": "MES COMMANDES", "es": "MIS PEDIDOS", "ja": "注文履歴", "de": "MEINE BESTELLUNGEN", "it": "I MIEI ORDINI", "pt": "MEUS PEDIDOS", "zh-Hans": "我的订单", "ru": "МОИ ЗАКАЗЫ", "ko": "내 주문"},
    "ORDER STATUS": {"en": "ORDER STATUS", "fr": "STATUT", "es": "ESTADO", "ja": "注文状況", "de": "BESTELLSTATUS", "it": "STATO ORDINE", "pt": "STATUS DO PEDIDO", "zh-Hans": "订单状态", "ru": "СТАТУС ЗАКАЗА", "ko": "주문 상태"},
    "CANCEL ORDER": {"en": "CANCEL ORDER", "fr": "ANNULER LA COMMANDE", "es": "CANCELAR PEDIDO", "ja": "注文をキャンセル", "de": "BESTELLUNG STORNIEREN", "it": "ANNULLA ORDINE", "pt": "CANCELAR PEDIDO", "zh-Hans": "取消订单", "ru": "ОТМЕНИТЬ ЗАКАЗ", "ko": "주문 취소"},
    "Fetching your orders...": {"en": "Fetching your orders...", "fr": "Récupération...", "es": "Obteniendo pedidos...", "ja": "注文を取得中...", "de": "Bestellungen werden abgerufen...", "it": "Recupero ordini...", "pt": "Buscando seus pedidos...", "zh-Hans": "正在获取订单...", "ru": "Получение ваших заказов...", "ko": "주문 불러오는 중..."},
    "Delivered On": {"en": "Delivered On", "fr": "Livré le", "es": "Entregado el", "ja": "配達完了日", "de": "Geliefert am", "it": "Consegnato il", "pt": "Entregue em", "zh-Hans": "交付于", "ru": "Доставлено", "ko": "배달 완료일"},
    "Status": {"en": "Status", "fr": "Statut", "es": "Estado", "ja": "ステータス", "de": "Status", "it": "Stato", "pt": "Status", "zh-Hans": "状态", "ru": "Статус", "ko": "상태"},
    "Tracking": {"en": "Tracking", "fr": "Suivi", "es": "Seguimiento", "ja": "追跡", "de": "Sendungsverfolgung", "it": "Tracciamento", "pt": "Rastreamento", "zh-Hans": "追踪", "ru": "Отслеживание", "ko": "추적"},

    # Products & Shop
    "Brands": {"en": "Brands", "fr": "Marques", "es": "Marcas", "ja": "ブランド", "de": "Marken", "it": "Marche", "pt": "Marcas", "zh-Hans": "品牌", "ru": "Бренды", "ko": "브랜드"},
    "Filter": {"en": "Filter", "fr": "Filtrer", "es": "Filtrar", "ja": "絞り込み", "de": "Filter", "it": "Filtra", "pt": "Filtrar", "zh-Hans": "筛选", "ru": "Фильтр", "ko": "필터"},
    "Filters": {"en": "Filters", "fr": "Filtres", "es": "Filtros", "ja": "フィルター", "de": "Filter", "it": "Filtri", "pt": "Filtros", "zh-Hans": "筛选器", "ru": "Фильтры", "ko": "필터"},
    "Sort By": {"en": "Sort By", "fr": "Trier par", "es": "Ordenar por", "ja": "並び替え", "de": "Sortieren nach", "it": "Ordina per", "pt": "Ordenar Por", "zh-Hans": "排序方式", "ru": "Сортировать по", "ko": "정렬 기준"},
    "Sort": {"en": "Sort", "fr": "Trier", "es": "Ordenar", "ja": "並び替え", "de": "Sortieren", "it": "Ordina", "pt": "Ordenar", "zh-Hans": "排序", "ru": "Сортировать", "ko": "정렬"},
    "See All": {"en": "See All", "fr": "Voir tout", "es": "Ver todo", "ja": "すべて見る", "de": "Alle ansehen", "it": "Vedi Tutti", "pt": "Ver Tudo", "zh-Hans": "查看全部", "ru": "Посмотреть все", "ko": "모두 보기"},
    "Size / Variant": {"en": "Size / Variant", "fr": "Taille / Variante", "es": "Talla / Variante", "ja": "サイズ/バリエーション", "de": "Größe / Variante", "it": "Taglia / Variante", "pt": "Tamanho / Variante", "zh-Hans": "尺寸 / 变体", "ru": "Размер / Вариант", "ko": "크기 / 옵션"},
    "Description": {"en": "Description", "fr": "Description", "es": "Descripción", "ja": "説明", "de": "Beschreibung", "it": "Descrizione", "pt": "Descrição", "zh-Hans": "描述", "ru": "Описание", "ko": "설명"},
    "CUSTOMER REVIEWS": {"en": "CUSTOMER REVIEWS", "fr": "AVIS CLIENTS", "es": "OPINIONES DE CLIENTES", "ja": "カスタマーレビュー", "de": "KUNDENBEWERTUNGEN", "it": "RECENSIONI CLIENTI", "pt": "AVALIAÇÕES DE CLIENTES", "zh-Hans": "客户评价", "ru": "ОТЗЫВЫ КЛИЕНТОВ", "ko": "고객 리뷰"},
    "ADD REVIEW": {"en": "ADD REVIEW", "fr": "AJOUTER UN AVIS", "es": "AÑADIR OPINIÓN", "ja": "レビューを追加", "de": "BEWERTUNG HINZUFÜGEN", "it": "AGGIUNGI RECENSIONE", "pt": "ADICIONAR AVALIAÇÃO", "zh-Hans": "添加评价", "ru": "ДОБАВИТЬ ОТЗЫВ", "ko": "리뷰 추가"},
    "SUBMIT REVIEW": {"en": "SUBMIT REVIEW", "fr": "SOUMETTRE L'AVIS", "es": "ENVIAR OPINIÓN", "ja": "レビューを送信", "de": "BEWERTUNG ABSENDEN", "it": "INVIA RECENSIONE", "pt": "ENVIAR AVALIAÇÃO", "zh-Hans": "提交评价", "ru": "ОТПРАВИТЬ ОТЗЫВ", "ko": "리뷰 제출"},
    "LEAVE A REVIEW": {"en": "LEAVE A REVIEW", "fr": "LAISSER UN AVIS", "es": "DEJAR UNA OPINIÓN", "ja": "レビューを残す", "de": "BEWERTUNG ABGEBEN", "it": "LASCIA UNA RECENSIONE", "pt": "DEIXE UMA AVALIAÇÃO", "zh-Hans": "留下评价", "ru": "ОСТАВИТЬ ОТЗЫВ", "ko": "리뷰 남기기"},
    "TAP TO RATE": {"en": "TAP TO RATE", "fr": "APPUYEZ POUR NOTER", "es": "TOCA PARA VALORAR", "ja": "タップして評価", "de": "ZUM BEWERTEN TIPPEN", "it": "TOCCA PER VALUTARE", "pt": "TOQUE PARA AVALIAR", "zh-Hans": "轻触评分", "ru": "НАЖМИТЕ ДЛЯ ОЦЕНКИ", "ko": "탭하여 평가"},
    "Verified & Guaranteed Genuine": {"en": "Verified & Guaranteed Genuine", "fr": "Authenticité Vérifiée et Garantie", "es": "Autenticidad Verificada y Garantizada", "ja": "正規品保証済み", "de": "Verifiziert & Garantiert echt", "it": "Verificato e Garantito Autentico", "pt": "Autenticidade Verificada e Garantida", "zh-Hans": "正品验证和保证", "ru": "Проверено и гарантировано подлинно", "ko": "정품 인증 및 보증"},
    "No products found": {"en": "No products found", "fr": "Aucun produit trouvé", "es": "No se encontraron productos", "ja": "商品が見つかりません", "de": "Keine Produkte gefunden", "it": "Nessun prodotto trovato", "pt": "Nenhum produto encontrado", "zh-Hans": "未找到产品", "ru": "Продукты не найдены", "ko": "제품을 찾을 수 없습니다"},
    "Search products, brands...": {"en": "Search products, brands...", "fr": "Rechercher produits, marques...", "es": "Buscar productos, marcas...", "ja": "商品、ブランドを検索...", "de": "Produkte, Marken suchen...", "it": "Cerca prodotti, marche...", "pt": "Procurar produtos, marcas...", "zh-Hans": "搜索产品、品牌...", "ru": "Поиск продуктов, брендов...", "ko": "제품, 브랜드 검색..."},

    # Wishlist & Addresses
    "WISHLIST": {"en": "WISHLIST", "fr": "FAVORIS", "es": "FAVORITOS", "ja": "お気に入り", "de": "WUNSCHLISTE", "it": "LISTA DESIDERI", "pt": "LISTA DE DESEJOS", "zh-Hans": "心愿单", "ru": "ИЗБРАННОЕ", "ko": "위시리스트"},
    "Your Wishlist is Empty": {"en": "Your Wishlist is Empty", "fr": "Vos favoris sont vides", "es": "Tus favoritos están vacíos", "ja": "お気に入りは空です", "de": "Ihre Wunschliste ist leer", "it": "La tua Lista Desideri è Vuota", "pt": "Sua Lista de Desejos está Vazia", "zh-Hans": "您的心愿单是空的", "ru": "Ваш список избранного пуст", "ko": "위시리스트가 비어 있습니다"},
    "SHIPPING ADDRESSES": {"en": "SHIPPING ADDRESSES", "fr": "ADRESSES DE LIVRAISON", "es": "DIRECCIONES DE ENVÍO", "ja": "お届け先住所", "de": "LIEFERADRESSEN", "it": "INDIRIZZI DI SPEDIZIONE", "pt": "ENDEREÇOS DE ENVIO", "zh-Hans": "配送地址", "ru": "АДРЕСА ДОСТАВКИ", "ko": "배송지 주소"},
    "ADD NEW ADDRESS": {"en": "ADD NEW ADDRESS", "fr": "NOUVELLE ADRESSE", "es": "NUEVA DIRECCIÓN", "ja": "新しい住所を追加", "de": "NEUE ADRESSE HINZUFÜGEN", "it": "AGGIUNGI NUOVO INDIRIZZO", "pt": "ADICIONAR NOVO ENDEREÇO", "zh-Hans": "添加新地址", "ru": "ДОБАВИТЬ НОВЫЙ АДРЕС", "ko": "새 주소 추가"},
    "SAVE FULL ADDRESS": {"en": "SAVE FULL ADDRESS", "fr": "ENREGISTRER L'ADRESSE", "es": "GUARDAR DIRECCIÓN", "ja": "住所を保存", "de": "VOLLSTÄNDIGE ADRESSE SPEICHERN", "it": "SALVA INDIRIZZO COMPLETO", "pt": "SALVAR ENDEREÇO COMPLETO", "zh-Hans": "保存完整地址", "ru": "СОХРАНИТЬ ПОЛНЫЙ АДРЕС", "ko": "전체 주소 저장"},
    "NO SAVED ADDRESSES": {"en": "NO SAVED ADDRESSES", "fr": "AUCUNE ADRESSE ENREGISTRÉE", "es": "NO HAY DIRECCIONES", "ja": "保存された住所はありません", "de": "KEINE GESPEICHERTEN ADRESSEN", "it": "NESSUN INDIRIZZO SALVATO", "pt": "NENHUM ENDEREÇO SALVO", "zh-Hans": "没有保存的地址", "ru": "НЕТ СОХРАНЕННЫХ АДРЕСОВ", "ko": "저장된 주소 없음"},
    "Select Shipping Address": {"en": "Select Shipping Address", "fr": "Sélectionner l'adresse", "es": "Seleccionar Dirección", "ja": "お届け先住所を選択", "de": "Lieferadresse auswählen", "it": "Seleziona Indirizzo di Spedizione", "pt": "Selecione o Endereço de Envio", "zh-Hans": "选择送货地址", "ru": "Выберите адрес доставки", "ko": "배송지 주소 선택"},

    # Appointments
    "Book a Store Visit": {"en": "Book a Store Visit", "fr": "Réserver une visite en boutique", "es": "Reservar visita a tienda", "ja": "来店予約", "de": "Filialbesuch buchen", "it": "Prenota una visita in negozio", "pt": "Agendar Visita à Loja", "zh-Hans": "预约到店访问", "ru": "Забронировать визит в магазин", "ko": "매장 방문 예약"},
    "SELECT DATE & TIME": {"en": "SELECT DATE & TIME", "fr": "SÉLECTIONNER DATE & HEURE", "es": "SELECCIONAR FECHA Y HORA", "ja": "日時を選択", "de": "DATUM & UHRZEIT WÄHLEN", "it": "SELEZIONA DATA E ORA", "pt": "SELECIONE DATA E HORA", "zh-Hans": "选择日期和时间", "ru": "ВЫБЕРИТЕ ДАТУ И ВРЕМЯ", "ko": "날짜 및 시간 선택"},
    "SPECIAL REQUESTS": {"en": "SPECIAL REQUESTS", "fr": "DEMANDES SPÉCIALES", "es": "PETICIONES ESPECIALES", "ja": "特別なご要望", "de": "BESONDERE WÜNSCHE", "it": "RICHIESTE SPECIALI", "pt": "PEDIDOS ESPECIAIS", "zh-Hans": "特别要求", "ru": "ОСОБЫЕ ПОЖЕЛАНИЯ", "ko": "특별 요청"},
    "APPOINTMENT SECURED": {"en": "APPOINTMENT SECURED", "fr": "RENDEZ-VOUS CONFIRMÉ", "es": "CITA CONFIRMADA", "ja": "予約確定", "de": "TERMIN GESICHERT", "it": "APPUNTAMENTO FISSATO", "pt": "AGENDAMENTO CONFIRMADO", "zh-Hans": "预约已确定", "ru": "ВСТРЕЧА ЗАБРОНИРОВАНА", "ko": "예약 확정됨"},
    "BOOKED": {"en": "BOOKED", "fr": "RÉSERVÉ", "es": "RESERVADO", "ja": "予約済み", "de": "GEBUCHT", "it": "PRENOTATO", "pt": "RESERVADO", "zh-Hans": "已预订", "ru": "ЗАБРОНИРОВАНО", "ko": "예약됨"},

    # Offers
    "ACTIVE OFFERS": {"en": "ACTIVE OFFERS", "fr": "OFFRES ACTIVES", "es": "OFERTAS ACTIVAS", "ja": "オファー", "de": "AKTIVE ANGEBOTE", "it": "OFFERTE ATTIVE", "pt": "OFERTAS ATIVAS", "zh-Hans": "有效优惠", "ru": "АКТИВНЫЕ ПРЕДЛОЖЕНИЯ", "ko": "활성 혜택"},
    "No Active Offers": {"en": "No Active Offers", "fr": "Aucune offre", "es": "Sin ofertas", "ja": "オファーはありません", "de": "Keine aktiven Angebote", "it": "Nessuna Offerta Attiva", "pt": "Nenhuma Oferta Ativa", "zh-Hans": "没有有效的优惠", "ru": "Нет активных предложений", "ko": "활성 혜택 없음"},
    "APPLY": {"en": "APPLY", "fr": "APPLIQUER", "es": "APLICAR", "ja": "適用", "de": "ANWENDEN", "it": "APPLICA", "pt": "APLICAR", "zh-Hans": "应用", "ru": "ПРИМЕНИТЬ", "ko": "적용"},
    "OFF": {"en": "OFF", "fr": "DE RÉDUCTION", "es": "DTO", "ja": "オフ", "de": "RABATT", "it": "SCONTO", "pt": "OFF", "zh-Hans": "折扣", "ru": "СКИДКА", "ko": "할인"},

    # Dynamic Product Descriptions & Names
    "Grand Bal Plissé Soleil": {"en": "Grand Bal Plissé Soleil", "fr": "Grand Bal Plissé Soleil", "es": "Grand Bal Plissé Soleil", "ja": "グラン バル プリセ ソレイユ", "de": "Grand Bal Plissé Soleil", "it": "Grand Bal Plissé Soleil", "pt": "Grand Bal Plissé Soleil", "zh-Hans": "Grand Bal Plissé Soleil 腕表", "ru": "Grand Bal Plissé Soleil", "ko": "그랑 발 플리세 솔레이"},
    "The Grand Bal Plissé Soleil automatic watch features a mesmerizing oscillating weight inspired by Dior Haute Couture. Crafted in steel and gold with a mother-of-pearl dial, this 36mm masterpiece embodies the art of movement.": {
        "en": "The Grand Bal Plissé Soleil automatic watch features a mesmerizing oscillating weight inspired by Dior Haute Couture. Crafted in steel and gold with a mother-of-pearl dial, this 36mm masterpiece embodies the art of movement.",
        "fr": "La montre automatique Grand Bal Plissé Soleil est dotée d'une masse oscillante envoûtante inspirée de la Haute Couture Dior. Fabriqué en acier et en or avec un cadran en nacre, ce chef-d'œuvre de 36 mm incarne l'art du mouvement.",
        "es": "El reloj automático Grand Bal Plissé Soleil presenta una fascinante masa oscilante inspirada en la Alta Costura de Dior. Elaborada en acero y oro con esfera de nácar, esta obra maestra de 36 mm encarna el arte del movimiento.",
        "ja": "「グラン バル プリセ ソレイユ」オートマティック ウォッチは、ディオールのオートクチュールにインスパイアされた魅惑的なローターを備えています。スチールとゴールドで作られ、マザーオブパールのダイヤルを備えたこの36mmの傑作は、動きの芸術を体現しています。",
        "de": "Die Automatikuhr Grand Bal Plissé Soleil verfügt über eine faszinierende Schwungmasse, inspiriert von Dior Haute Couture. Dieses 36-mm-Meisterwerk aus Stahl und Gold mit Perlmuttzifferblatt verkörpert die Kunst der Bewegung.",
        "it": "L'orologio automatico Grand Bal Plissé Soleil presenta un'affascinante massa oscillante ispirata alla Haute Couture Dior. Realizzato in acciaio e oro con quadrante in madreperla, questo capolavoro da 36 mm incarna l'arte del movimento.",
        "pt": "O relógio automático Grand Bal Plissé Soleil apresenta uma massa oscilante hipnotizante inspirada na Alta Costura da Dior. Fabricada em aço e ouro com mostrador em madrepérola, esta obra-prima de 36 mm incorpora a arte do movimento.",
        "zh-Hans": "Grand Bal Plissé Soleil 自动腕表配备了从 Dior 高级定制时装中汲取灵感的迷人摆陀。这款 36 毫米杰作采用精钢和黄金打造，配以珍珠母贝表盘，彰显动感艺术。",
        "ru": "Автоматические часы Grand Bal Plissé Soleil оснащены завораживающим ротором, вдохновленным высокой модой Dior. Этот шедевр диаметром 36 мм, выполненный из стали и золота с перламутровым циферблатом, воплощает искусство движения.",
        "ko": "그랑 발 플리세 솔레이 오토매틱 워치는 디올 오뜨 꾸뛰르에서 영감을 받은 매혹적인 로터가 특징입니다. 스틸과 골드 소재로 제작되었으며 자개 다이얼이 있는 이 36mm 걸작은 움직임의 예술을 구현합니다."
    },

    "Rose des Vents Bracelet": {"en": "Rose des Vents Bracelet", "fr": "Bracelet Rose des Vents", "es": "Pulsera Rose des Vents", "ja": "ローズ デ ヴァン ブレスレット", "de": "Rose des Vents Armband", "it": "Bracciale Rose des Vents", "pt": "Pulseira Rose des Vents", "zh-Hans": "Rose des Vents 手链", "ru": "Браслет Rose des Vents", "ko": "로즈 드 방 팔찌"},
    "The Rose des Vents bracelet, a Victoire de Castellane creation, features the Maison's lucky star set in 18K yellow gold with turquoise and a diamond. A contemporary talisman inspired by Christian Dior's love of the stars.": {
        "en": "The Rose des Vents bracelet, a Victoire de Castellane creation, features the Maison's lucky star set in 18K yellow gold with turquoise and a diamond. A contemporary talisman inspired by Christian Dior's love of the stars.",
        "fr": "Le bracelet Rose des Vents, une création de Victoire de Castellane, met en scène l'étoile porte-bonheur de la Maison sertie sur de l'or jaune 18 carats avec de la turquoise et un diamant. Un talisman contemporain inspiré par l'amour de Christian Dior pour les étoiles.",
        "es": "La pulsera Rose des Vents, una creación de Victoire de Castellane, presenta la estrella de la suerte de la Maison en oro amarillo de 18 quilates con turquesa y un diamante. Un talismán contemporáneo inspirado en el amor de Christian Dior por las estrellas.",
        "ja": "ヴィクトワール・ドゥ・カステラーヌによる作品「ローズ デ ヴァン」ブレスレットは、ターコイズとダイヤモンドをあしらった18Kイエローゴールドのメゾンのラッキースターが特徴です。クリスチャン・ディオールの星への愛からインスピレーションを得た現代的なお守り。",
        "de": "Das Armband Rose des Vents, eine Kreation von Victoire de Castellane, präsentiert den Glücksstern der Maison in 18 Karat Gelbgold mit Türkis und einem Diamanten. Ein zeitgemäßer Talisman, inspiriert von Christian Diors Liebe zu den Sternen.",
        "it": "Il bracciale Rose des Vents, creazione di Victoire de Castellane, presenta la stella portafortuna della Maison incastonata in oro giallo 18 carati con turchese e un diamante. Un talismano contemporaneo ispirato all'amore di Christian Dior per le stelle.",
        "pt": "A pulseira Rose des Vents, uma criação de Victoire de Castellane, apresenta a estrela da sorte da Maison em ouro amarelo de 18 quilates com turquesa e um diamante. Um talismã contemporâneo inspirado no amor de Christian Dior pelas estrelas.",
        "zh-Hans": "Rose des Vents 手链是 Victoire de Castellane 的作品，采用 18K 黄金镶嵌绿松石和钻石，展现了品牌标志性的幸运星。这是一件从克里斯汀·迪奥对星星的热爱中汲取灵感的现代护身符。",
        "ru": "Браслет Rose des Vents, творение Виктуар де Кастеллан, украшен счастливой звездой Дома из 18-каратного желтого золота с бирюзой и бриллиантом. Современный талисман, вдохновленный любовью Кристиана Диора к звездам.",
        "ko": "빅투아르 드 카스텔란이 디자인한 로즈 드 방 팔찌는 터키석과 다이아몬드가 세팅된 18K 옐로우 골드 소재의 메종 럭키 스타가 특징입니다. 크리스챤 디올의 별에 대한 사랑에서 영감을 받은 현대적인 부적입니다."
    },

    "Oblique Jacquard Jacket": {"en": "Oblique Jacquard Jacket", "fr": "Veste Jacquard Oblique", "es": "Chaqueta Jacquard Oblique", "ja": "オブリーク ジャカード ジャケット", "de": "Oblique Jacquard-Jacke", "it": "Giacca Jacquard Oblique", "pt": "Jaqueta Jacquard Oblique", "zh-Hans": "Oblique 提花夹克", "ru": "Жакет из жаккарда Oblique", "ko": "오블리크 자카드 재킷"},
    "This iconic Dior Oblique jacquard jacket features the signature monogram motif reimagined by Kim Jones. Crafted from technical cotton blend with a relaxed silhouette. A modern wardrobe essential from the Maison.": {
        "en": "This iconic Dior Oblique jacquard jacket features the signature monogram motif reimagined by Kim Jones. Crafted from technical cotton blend with a relaxed silhouette. A modern wardrobe essential from the Maison.",
        "fr": "Cette veste emblématique en jacquard Dior Oblique arbore le motif monogramme signature réimaginé par Kim Jones. Fabriquée dans un mélange de coton technique avec une silhouette décontractée. Un essentiel de la garde-robe moderne de la Maison.",
        "es": "Esta icónica chaqueta jacquard Dior Oblique presenta el característico motivo monograma reinventado por Kim Jones. Confeccionada en una mezcla de algodón técnico con una silueta relajada. Un elemento esencial del armario moderno de la Maison.",
        "ja": "アイコニックなディオール オブリーク ジャカード ジャケットには、キム・ジョーンズによって再構築されたシグネチャーのモノグラム モチーフが特徴です。リラックスしたシルエットのテクニカルコットン混紡で作られています。メゾンのモダンなワードローブの必需品。",
        "de": "Diese ikonische Dior Oblique Jacquard-Jacke besticht durch das charakteristische Monogramm-Motiv, neu interpretiert von Kim Jones. Gefertigt aus einem technischen Baumwollmischgewebe mit entspannter Silhouette. Ein modernes Garderoben-Essential der Maison.",
        "it": "Questa iconica giacca in jacquard Dior Oblique presenta il caratteristico motivo monogramma reinventato da Kim Jones. Realizzata in misto cotone tecnico con silhouette rilassata. Un capo essenziale per il guardaroba moderno della Maison.",
        "pt": "Esta icônica jaqueta jacquard Dior Oblique apresenta o motivo do monograma reinventado por Kim Jones. Confeccionada em mistura de algodão técnico com silhueta relaxada. Uma peça essencial para o guarda-roupa moderno da Maison.",
        "zh-Hans": "这款标志性的 Dior Oblique 提花夹克采用 Kim Jones 重新构想的标志性字母组合图案。由科技棉混纺制成，廓形休闲。来自该品牌的现代衣橱必备单品。",
        "ru": "Этот культовый жакет из жаккарда Dior Oblique украшен фирменным мотивом-монограммой, переосмысленным Кимом Джонсом. Изготовлен из технического хлопка в расслабленном силуэте. Современная базовая вещь гардероба от Дома.",
        "ko": "이 아이코닉한 디올 오블리크 자카드 재킷은 킴 존스가 재해석한 시그니처 모노그램 모티프가 특징입니다. 여유로운 실루엣의 테크니컬 코튼 블렌드로 제작되었습니다. 메종의 모던한 옷장 필수품."
    },

    "Lady Dior": {"en": "Lady Dior", "fr": "Lady Dior", "es": "Lady Dior", "ja": "レディ ディオール", "de": "Lady Dior", "it": "Lady Dior", "pt": "Lady Dior", "zh-Hans": "Lady Dior 戴妃包", "ru": "Lady Dior", "ko": "레이디 디올"},
    "The Lady Dior — an icon since 1995, beloved by Princess Diana. Crafted in supple cannage lambskin with gold-tone D.I.O.R. charms. The quilted motif is inspired by the Napoleon III chairs Christian Dior loved.": {
        "en": "The Lady Dior — an icon since 1995, beloved by Princess Diana. Crafted in supple cannage lambskin with gold-tone D.I.O.R. charms. The quilted motif is inspired by the Napoleon III chairs Christian Dior loved.",
        "fr": "Le Lady Dior — une icône depuis 1995, apprécié par la Princesse Diana. Fabriqué en cuir d'agneau souple motif cannage avec des charms D.I.O.R. dorés. Le motif matelassé s'inspire des chaises Napoléon III que Christian Dior aimait.",
        "es": "El Lady Dior — un icono desde 1995, adorado por la Princesa Diana. Elaborado en piel de cordero flexible con motivo cannage y colgantes D.I.O.R. dorados. El motivo acolchado se inspira en las sillas Napoleón III que amaba Christian Dior.",
        "ja": "レディ ディオール — ダイアナ妃に愛された1995年以来のアイコン。ゴールドトーンのD.I.O.R.チャームが付いた、しなやかなカナージュ ラムスキンで作られています。キルティングモチーフはクリスチャン・ディオールが愛したナポレオン3世の椅子からインスピレーションを得ています。",
        "de": "Die Lady Dior — eine Ikone seit 1995, geliebt von Prinzessin Diana. Gefertigt aus geschmeidigem Cannage-Lammleder mit goldfarbenen D.I.O.R.-Anhängern. Das Steppmuster ist von den Napoleon-III-Stühlen inspiriert, die Christian Dior liebte.",
        "it": "La Lady Dior — un'icona dal 1995, amata dalla Principessa Diana. Realizzata in morbida pelle d'agnello cannage con ciondoli D.I.O.R. color oro. Il motivo trapuntato si ispira alle sedie Napoleone III amate da Christian Dior.",
        "pt": "A Lady Dior — um ícone desde 1995, adorada pela Princesa Diana. Fabricada em pele de cordeiro macia com motivo cannage e amuletos D.I.O.R. dourados. O motivo acolchoado inspira-se nas cadeiras Napoleão III que Christian Dior adorava.",
        "zh-Hans": "Lady Dior 戴妃包 — 自 1995 年以来的标志，深受戴安娜王妃的喜爱。采用柔软的藤格纹小羊皮制成，配有金色 D.I.O.R. 吊饰。绗缝图案的灵感来自克里斯汀·迪奥钟爱的拿破仑三世椅子。",
        "ru": "Lady Dior — икона с 1995 года, любимая принцессой Дианой. Выполнена из эластичной овечьей кожи с узором cannage и золотистыми подвесками D.I.O.R. Стеганый мотив вдохновлен стульями Наполеона III, которые любил Кристиан Диор.",
        "ko": "레이디 디올 — 다이애나 왕세자비가 사랑한 1995년 이후의 아이콘. 골드 톤 D.I.O.R. 참 장식이 있는 유연한 까나쥬 램스킨으로 제작되었습니다. 퀼팅 모티프는 크리스챤 디올이 사랑했던 나폴레옹 3세 의자에서 영감을 받았습니다."
    },

    "B23 High-Top Sneakers": {"en": "B23 High-Top Sneakers", "fr": "Baskets Montantes B23", "es": "Zapatillas Altas B23", "ja": "B23 ハイトップ スニーカー", "de": "B23 High-Top-Sneaker", "it": "Sneakers Alte B23", "pt": "Tênis Cano Alto B23", "zh-Hans": "B23 高帮运动鞋", "ru": "Высокие кроссовки B23", "ko": "B23 하이탑 스니커즈"},
    "The B23 high-top sneaker features the Dior Oblique motif on transparent technical canvas. With a white rubber sole and calfskin details, it's a contemporary icon that bridges streetwear and haute couture.": {
        "en": "The B23 high-top sneaker features the Dior Oblique motif on transparent technical canvas. With a white rubber sole and calfskin details, it's a contemporary icon that bridges streetwear and haute couture.",
        "fr": "La sneaker montante B23 arbore le motif Dior Oblique sur une toile technique transparente. Avec sa semelle en gomme blanche et ses détails en cuir de veau, c'est une icône contemporaine à la croisée du streetwear et de la haute couture.",
        "es": "La zapatilla alta B23 presenta el motivo Dior Oblique sobre lona técnica transparente. Con suela de goma blanca y detalles en piel de becerro, es un icono contemporáneo que une el streetwear y la alta costura.",
        "ja": "B23 ハイトップスニーカーは、透明なテクニカルキャンバスにディオール オブリーク モチーフが特徴です。ホワイトのラバーソールとカーフスキンのディテールを備えた、ストリートウェアとオートクチュールの架け橋となる現代的なアイコンです。",
        "de": "Der B23 High-Top-Sneaker zeigt das Dior Oblique-Motiv auf transparentem technischem Canvas. Mit einer weißen Gummisohle und Kalbslederdetails ist er eine zeitgemäße Ikone, die Streetwear und Haute Couture verbindet.",
        "it": "La sneaker alta B23 presenta il motivo Dior Oblique su tela tecnica trasparente. Con suola in gomma bianca e dettagli in pelle di vitello, è un'icona contemporanea che unisce streetwear e haute couture.",
        "pt": "O tênis cano alto B23 apresenta o motivo Dior Oblique em lona técnica transparente. Com sola de borracha branca e detalhes em pele de bezerro, é um ícone contemporâneo que une streetwear e alta costura.",
        "zh-Hans": "B23 高帮运动鞋在透明科技帆布上呈现 Dior Oblique 图案。搭配白色橡胶鞋底和牛皮革细节，这是连接街头服饰和高级定制时装的现代标志。",
        "ru": "Высокие кроссовки B23 украшены мотивом Dior Oblique на прозрачной технической парусине. С белой резиновой подошвой и деталями из телячьей кожи, это современная икона, объединяющая уличную моду и высокую моду.",
        "ko": "B23 하이탑 스니커즈는 투명한 테크니컬 캔버스에 디올 오블리크 모티프를 특징으로 합니다. 화이트 러버 솔과 카프스킨 디테일을 갖춘 스트리트웨어와 오뜨 꾸뛰르를 연결하는 현대적인 아이콘입니다."
    },

    "Sauvage Elixir": {"en": "Sauvage Elixir", "fr": "Sauvage Elixir", "es": "Sauvage Elixir", "ja": "ソヴァージュ エリクシール", "de": "Sauvage Elixir", "it": "Sauvage Elixir", "pt": "Sauvage Elixir", "zh-Hans": "旷野男士淬炼香精", "ru": "Sauvage Elixir", "ko": "소바쥬 엘릭서"},
    "Sauvage Elixir is the most concentrated expression of the iconic Sauvage line. A rich elixir of spices, woods, and amber notes by François Demachy. A fragrance of raw, noble elegance for the modern man.": {
        "en": "Sauvage Elixir is the most concentrated expression of the iconic Sauvage line. A rich elixir of spices, woods, and amber notes by François Demachy. A fragrance of raw, noble elegance for the modern man.",
        "fr": "Sauvage Elixir est l'expression la plus concentrée de l'iconique gamme Sauvage. Un riche élixir d'épices, de bois et de notes ambrées créé par François Demachy. Une fragrance d'élégance brute et noble pour l'homme moderne.",
        "es": "Sauvage Elixir es la expresión más concentrada de la icónica línea Sauvage. Un rico elixir de especias, maderas y notas ambarinas creado por François Demachy. Una fragancia de elegancia cruda y noble para el hombre moderno.",
        "ja": "「ソヴァージュ エリクシール」は、アイコニックな「ソヴァージュ」ラインの最も凝縮された表現です。フランソワ・ドゥマシーによるスパイス、ウッド、アンバーノートの豊かなエリクシール。現代の男性のための、野性的で気高いエレガンスの香り。",
        "de": "Sauvage Elixir ist der konzentrierteste Ausdruck der ikonischen Sauvage-Linie. Ein reiches Elixier aus Gewürzen, Hölzern und Ambernoten von François Demachy. Ein Duft von rauer, edler Eleganz für den modernen Mann.",
        "it": "Sauvage Elixir è l'espressione più concentrata dell'iconica linea Sauvage. Un ricco elisir di spezie, legni e note ambrate di François Demachy. Una fragranza di cruda, nobile eleganza per l'uomo moderno.",
        "pt": "Sauvage Elixir é a expressão mais concentrada da icônica linha Sauvage. Um rico elixir de especiarias, madeiras e notas de âmbar de François Demachy. Uma fragrância de elegância crua e nobre para o homem moderno.",
        "zh-Hans": "旷野男士淬炼香精是标志性旷野系列中浓度最高的一款。由 François Demachy 调制的充满香料、木质和琥珀香调的浓郁淬炼精粹。一款专为现代男士打造的充满原始高贵优雅气息的香水。",
        "ru": "Sauvage Elixir — это самое концентрированное выражение культовой линии Sauvage. Богатый эликсир специй, дерева и амбровых нот от Франсуа Демаши. Аромат сырой, благородной элегантности для современного мужчины.",
        "ko": "소바쥬 엘릭서는 상징적인 소바쥬 라인의 가장 농축된 표현입니다. 프랑수아 드마쉬의 스파이스, 우드, 앰버 노트의 풍부한 엘릭서. 현대 남성을 위한 거칠고 고귀한 우아함의 향수."
    },

    "DiorBlackSuit Sunglasses": {"en": "DiorBlackSuit Sunglasses", "fr": "Lunettes de Soleil DiorBlackSuit", "es": "Gafas de Sol DiorBlackSuit", "ja": "DiorBlackSuit サングラス", "de": "DiorBlackSuit Sonnenbrille", "it": "Occhiali da Sole DiorBlackSuit", "pt": "Óculos de Sol DiorBlackSuit", "zh-Hans": "DiorBlackSuit 太阳眼镜", "ru": "Солнцезащитные очки DiorBlackSuit", "ko": "DiorBlackSuit 선글라스"},
    "The DiorBlackSuit navigator sunglasses feature the CD Diamond signature on the temples. Crafted in lightweight metal with grey gradient lenses. A refined silhouette embodying Dior's timeless Parisian elegance.": {
        "en": "The DiorBlackSuit navigator sunglasses feature the CD Diamond signature on the temples. Crafted in lightweight metal with grey gradient lenses. A refined silhouette embodying Dior's timeless Parisian elegance.",
        "fr": "Les lunettes de soleil aviateur DiorBlackSuit arborent la signature CD Diamond sur les branches. Fabriquées en métal léger avec des verres dégradés gris. Une silhouette raffinée incarnant l'élégance parisienne intemporelle de Dior.",
        "es": "Las gafas de sol tipo aviador DiorBlackSuit presentan la firma CD Diamond en las patillas. Elaboradas en metal ligero con lentes degradadas grises. Una silueta refinada que encarna la atemporal elegancia parisina de Dior.",
        "ja": "DiorBlackSuit ナビゲーターサングラスは、テンプルにCDダイアモンドのシグネチャーをあしらっています。軽量メタルで作られ、グレーのグラデーションレンズを装備。ディオールの時代を超越したパリジャンのエレガンスを体現する洗練されたシルエット。",
        "de": "Die DiorBlackSuit Piloten-Sonnenbrille präsentiert die CD Diamond-Signatur an den Bügeln. Gefertigt aus leichtem Metall mit grauen Verlaufsgläsern. Eine raffinierte Silhouette, die Diors zeitlose Pariser Eleganz verkörpert.",
        "it": "Gli occhiali da sole navigator DiorBlackSuit presentano la firma CD Diamond sulle aste. Realizzati in metallo leggero con lenti sfumate grigie. Una silhouette raffinata che incarna l'intramontabile eleganza parigina di Dior.",
        "pt": "Os óculos de sol modelo aviador DiorBlackSuit apresentam a assinatura CD Diamond nas hastes. Fabricados em metal leve com lentes em degradê cinzento. Uma silhueta refinada que personifica a elegância parisiense intemporal da Dior.",
        "zh-Hans": "DiorBlackSuit 飞行员太阳眼镜在镜腿上饰有 CD Diamond 标志。由轻质金属制成，配有灰色渐变镜片。精致的轮廓体现了迪奥永恒的巴黎优雅风情。",
        "ru": "Солнцезащитные очки-навигаторы DiorBlackSuit украшены подписью CD Diamond на дужках. Изготовлены из легкого металла с серыми градиентными линзами. Утонченный силуэт, воплощающий неподвластную времени парижскую элегантность Dior.",
        "ko": "DiorBlackSuit 내비게이터 선글라스는 템플의 CD 다이아몬드 시그니처가 특징입니다. 가벼운 금속으로 제작되었으며 그레이 그라데이션 렌즈가 있습니다. 디올의 시대를 초월한 파리지앵 엘레강스를 구현하는 세련된 실루엣."
    }
}

directory_base = "/Users/apple/Desktop/RSMS-User-iOS-App/User-Side-App"

for code, lang in languages.items():
    lproj_dir = os.path.join(directory_base, f"{code}.lproj")
    if not os.path.exists(lproj_dir):
        os.makedirs(lproj_dir)
        
    strings_path = os.path.join(lproj_dir, "Localizable.strings")
    
    content = f"/* Translations for {lang} */\n\n"
    for eng_key, langs_dict in translations.items():
        val = langs_dict.get(code, eng_key).replace('"', '\\"')
        content += f'"{eng_key}" = "{val}";\n'
        
    with open(strings_path, "w", encoding="utf-8") as f:
        f.write(content)
        
print("Successfully regenerated all 10 Localizable.strings files with FULL UI elements.")
