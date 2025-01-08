<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<xsl:output method="html" indent="yes" 
            doctype-public="-//W3C//DTD HTML 4.01//EN" 
            doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>

<!-- Main page template -->
<xsl:template match="/">
    <html>
        <head>
            <title>FMI IT Store</title>
            <style>
                .store-header {
                    text-align: center;
                    color: #2c3e50;
                    padding: 20px 0;
                    margin-bottom: 30px;
                    background: #ecf0f1;
                    border-bottom: 3px solid #3498db;
                }
                .store-header h1 {
                    font-size: 2.5em;
                    margin: 0;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                }
                body { font-family: Arial, sans-serif; margin: 20px; }
                .filters { 
                    margin-bottom: 20px;
                    text-align: center;
                }
                .product { 
                    border: 1px solid #ddd; 
                    padding: 10px; 
                    margin: 10px; 
                    display: inline-block; 
                    width: 300px;
                    height: 350px;
                    vertical-align: top;
                    overflow: hidden;
                    position: relative;
                }
                .product img { 
                    width: 180px; 
                    height: 180px; 
                    object-fit: contain;
                    display: block;
                    margin: 0 auto;
                }
                .product p:last-child {
                    position: absolute;
                    bottom: 10px;
                    right: 10px;
                    margin: 0;
                    font-weight: bold;
                }
                .hidden { display: none; }
                .product-detailed {
                    max-width: 800px;
                    margin: 20px auto;
                    padding: 30px;
                    background: #fff;
                    box-shadow: 0 0 20px rgba(0,0,0,0.1);
                    border-radius: 8px;
                }

                .product-detailed img {
                    width: 300px;
                    height: 300px;
                    object-fit: contain;
                    display: block;
                    margin: 0 auto 20px;
                }

                .product-detailed h3 {
                    color: #2c3e50;
                    font-size: 24px;
                    margin-bottom: 20px;
                    text-align: center;
                }

                .product-detailed h4 {
                    color: #34495e;
                    margin-top: 20px;
                    margin-bottom: 10px;
                    border-bottom: 2px solid #3498db;
                    padding-bottom: 5px;
                }

                .product-detailed p {
                    margin: 10px 0;
                    line-height: 1.6;
                    color: #555;
                }

                .product button {
                    display: block;
                    position: absolute;
                    bottom: 10px;
                    left: 10px;
                    padding: 10px 20px;
                    background: #3498db;
                    color: white;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                }

                .product button:hover {
                    background: #2980b9;
                }
                .product-detailed .price {
                    position: absolute;
                    bottom: 20px;
                    right: 20px;
                    font-weight: bold;
                    font-size: 1.2em;
                    color: #2c3e50;
                }

                .product-detailed {
                    position: relative;
                    padding-bottom: 60px;
                }

                .back-button {
                    position: absolute;
                    left: 20px;
                    padding: 10px 20px;
                    background: #e74c3c;
                    color: white;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                }

                .back-button:hover {
                    background: #c0392b;
                }
            </style>
            <script>
                function filterProducts() {
                    const type = document.getElementById('typeFilter').value;
                    const brand = document.getElementById('brandFilter').value;
                    const products = document.getElementsByClassName('product');
                    
                    for (let product of products) {
                        const productType = product.getAttribute('data-type');
                        const productBrand = product.getAttribute('data-brand');
                        product.classList.toggle('hidden', 
                            (type !== 'all' &amp;&amp; productType !== type) || 
                            (brand !== 'all' &amp;&amp; productBrand !== brand));
                    }
                }

                function sortProducts(criteria, ascending = true) {
                    const container = document.getElementById('products');
                    const products = [...container.getElementsByClassName('product')];
                    
                    products.sort((a, b) => {
                        if (criteria === 'price') {
                            const priceA = parseFloat(a.getAttribute('data-price'));
                            const priceB = parseFloat(b.getAttribute('data-price'));
                            return ascending ? priceA - priceB : priceB - priceA;
                        } else {
                            const nameA = a.getAttribute('data-name');
                            const nameB = b.getAttribute('data-name');
                            return ascending ? nameA.localeCompare(nameB) : nameB.localeCompare(nameA);
                        }
                    });

                    products.forEach(product => container.appendChild(product));
                }

                function showDetails(model) {
                    filterProducts();
                    const filters = document.getElementsByClassName('filters')[0];
                    filters.classList.toggle('hidden');
                    const products = document.getElementsByClassName('product');
                    for (let p of products) {
                        if (p.classList.contains('hidden')) continue;
                        p.classList.toggle('hidden');
                    }

                    const detailed = document.getElementById(`${model}-detailed`);
                    detailed.classList.toggle('hidden');
                }

                function refreshPage() {
                    const filters = document.getElementsByClassName('filters')[0];
                    filters.classList.remove('hidden');
                    const products = document.getElementsByClassName('product');
                    for (let p of products) {
                        p.classList.toggle('hidden');
                    }

                    const detailed = document.getElementsByClassName('product-detailed');
                    for (let d of detailed) {
                        d.classList.add('hidden');
                    }
                    
                    filterProducts();
                }
            </script>
        </head>
        <body>
            <div class="store-header">
                <h1>FMI IT Store</h1>
            </div>
            <div class="filters">
                <h3>Filter and Sort Options</h3>
                <select id="typeFilter" onchange="filterProducts()">
                    <option value="all">All Types</option>
                    <xsl:for-each select="catalog/products/product/@xsi:type[not(. = preceding::product/@xsi:type)]">
                        <option value="{.}">
                            <xsl:value-of select="concat(
                                translate(substring(., 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
                                substring(., 2, string-length(.) - 5),
                                's'
                            )"/>
                        </option>
                    </xsl:for-each>
                </select>
                
                <select id="brandFilter" onchange="filterProducts()">
                    <option value="all">All Brands</option>
                    <xsl:for-each select="catalog/brands/brand">
                        <option><xsl:value-of select="."/></option>
                    </xsl:for-each>
                </select>
                
                <select onchange="sortProducts(this.value.split('-')[0], this.value.split('-')[1] === 'asc')">
                    <option value="name-asc">Sort by Name (A-Z)</option>
                    <option value="name-desc">Sort by Name (Z-A)</option>
                    <option value="price-asc">Sort by Price (Low to High)</option>
                    <option value="price-desc">Sort by Price (High to Low)</option>
                </select>
            </div>

            <xsl:apply-templates select="catalog/products"/>
        </body>
    </html>
</xsl:template>

<!-- Load sorted products template -->
<xsl:template match="products">
    <div id="products">
        <xsl:for-each select="product">
            <xsl:sort select="name"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </div>
</xsl:template>

<!-- Product load template -->
<xsl:template match="product">
    <div class="product">
        <xsl:attribute name="id">
            <xsl:value-of select="model"/>
        </xsl:attribute>
        <xsl:attribute name="data-type">
            <xsl:value-of select="@xsi:type"/>
        </xsl:attribute>
        <xsl:attribute name="data-brand">
            <xsl:value-of select="brand"/>
        </xsl:attribute>
        <xsl:attribute name="data-name">
            <xsl:value-of select="name"/>
        </xsl:attribute>
        <xsl:attribute name="data-price">
            <xsl:choose>
                <xsl:when test="price/@currency = 'EUR'">
                    <xsl:value-of select="price * 1.95583"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="price"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        
        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="unparsed-entity-uri(image/@src)"/>
            </xsl:attribute>
        </img>
        <h3><xsl:value-of select="name"/></h3>
        <p>Brand: <xsl:value-of select="brand"/></p>
        <p>Model: <xsl:value-of select="model"/></p>
        <button onclick="showDetails('{model}')">Details</button>
        <p>Price: <xsl:value-of select="price"/>
            <xsl:value-of select="price/@currency"/>
        </p>
    </div>

    <div class="product-detailed hidden">
        <xsl:attribute name="id">
            <xsl:value-of select="concat(model, '-detailed')"></xsl:value-of>
        </xsl:attribute>

        <button class="back-button" onclick="refreshPage()">Back to List</button>

        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="unparsed-entity-uri(image/@src)"/>
            </xsl:attribute>
        </img>
        <h3><xsl:value-of select="name"/></h3>
        <p>Brand: <xsl:value-of select="brand"/></p>
        <p>Model: <xsl:value-of select="model"/></p>

        <xsl:if test="colors">
            <h4>Available colors:</h4>
            <xsl:for-each select="colors/color">
                <p><xsl:value-of select="."/></p>
            </xsl:for-each>
            <h4>Details</h4>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="@xsi:type='laptopType'">
                <p>Operating System: <xsl:value-of select="os"/></p>
                <p>Processor: <xsl:value-of select="processor"/></p>
                <p>RAM: <xsl:value-of select="ram"/> GB</p>
                <p>Storage: <xsl:value-of select="storage"/> <xsl:value-of select="storage/@unit"/></p>
                <h4>Display Specifications:</h4>
                <p>Resolution: <xsl:value-of select="display/resolution"/></p>
                <p>Refresh Rate: <xsl:value-of select="display/refreshRate"/> Hz</p>
                <p>Screen Size: <xsl:value-of select="display/diagonalSize"/> inches</p>
                <h4>Keyboard:</h4>
                <p>Type: <xsl:value-of select="keyboard/type"/></p>
                <p>Full-sized: <xsl:value-of select="keyboard/full-sized"/></p>
            </xsl:when>
            <xsl:when test="@xsi:type='keyboardType'">
                <p>Type: <xsl:value-of select="type"/></p>
                <p>Full-sized: <xsl:value-of select="full-sized"/></p>
                <p>Connectivity: <xsl:value-of select="connectivity"/></p>
            </xsl:when>
            <xsl:when test="@xsi:type='mouseType'">
                <p>DPI: <xsl:value-of select="dpi"/></p>
                <p>Buttons: <xsl:value-of select="buttons"/></p>
                <p>Connectivity: <xsl:value-of select="connectivity"/></p>
            </xsl:when>
            <xsl:when test="@xsi:type='displayType'">
                <p>Resolution: <xsl:value-of select="resolution"/></p>
                <p>Refresh Rate: <xsl:value-of select="refreshRate"/> Hz</p>
                <p>Screen Size: <xsl:value-of select="diagonalSize"/> inches</p>
            </xsl:when>
            <xsl:when test="@xsi:type='desktopType'">
                <p>Operating System: <xsl:value-of select="os"/></p>
                <p>Processor: <xsl:value-of select="processor"/></p>
                <p>RAM: <xsl:value-of select="ram"/> GB</p>
                <p>Storage: <xsl:value-of select="storage"/> <xsl:value-of select="storage/@unit"/></p>
            </xsl:when>
        </xsl:choose>

        <p class="price">Price: <xsl:value-of select="price"/>
            <xsl:value-of select="price/@currency"/>
        </p>
    </div>
</xsl:template>

</xsl:stylesheet>