namespace AgendaMedica.Models;

public class MedicoResponse
{
    public int Id { get; set; }
    public string Nombre { get; set; } = null!;
    public string ApellidoPaterno { get; set; } = null!;
    public string? ApellidoMaterno { get; set; }
    public int EspecialidadId { get; set; }
    public string EspecialidadNombre { get; set; } = null!;
    public int DuracionMinutos { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaCreacion { get; set; }
}

public class HorarioResponse
{
    public int Id { get; set; }
    public int DiaSemana { get; set; }
    public TimeSpan HoraInicio { get; set; }
    public TimeSpan HoraFin { get; set; }
}

public class HorarioDisponibleResponse
{
    public int MedicoId { get; set; }
    public DateTime FechaHoraInicio { get; set; }
    public DateTime FechaHoraFin { get; set; }
    public string? EspecialidadNombre { get; set; }
    public int DuracionMinutos { get; set; }
}
