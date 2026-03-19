using AgendaMedica.Middleware;
using AgendaMedica.Services;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("AgendaMedica")
    ?? throw new InvalidOperationException("Falta la cadena de conexión 'AgendaMedica' en appsettings.json.");


builder.Services.AddControllers();
builder.Services.AddScoped(_ => new MedicoService(connectionString));
builder.Services.AddScoped(_ => new PacienteService(connectionString));
builder.Services.AddScoped(_ => new CitaService(connectionString));

var app = builder.Build();


app.UseMiddleware<ErrorMiddleware>();


app.MapControllers();

app.Run();
